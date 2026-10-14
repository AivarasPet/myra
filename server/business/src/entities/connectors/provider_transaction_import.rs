use connectors::models::transaction::ProviderTransaction;
use rust_decimal::Decimal;
use time::OffsetDateTime;
use uuid::Uuid;

use crate::dtos::entry_dto::EntryDto;
use crate::dtos::transaction_dto::{
    AssetPurchaseMetadataDto, AssetSaleMetadataDto, CashDividendMetadataDto,
    RegularTransactionMetadataDto, TransactionDto, TransactionTypeDto, TransactionVisibilityDto,
};
use crate::entities::transactions::metadata::ConnectorLinkMeta;
use crate::entities::transactions::transaction::Transaction;
use crate::entities::transactions::transaction_types::create_transaction_from_dto;

const IMPORT_CATEGORY_ID: i32 = 76;

// TODO: move the Trading212 ticker handling (aliases, `_EQ`/`_US`/`l` suffixes) to its mapper.
const TICKER_ALIASES: &[(&str, &str)] = &[("FB_US_EQ", "META.NASDAQ"), ("JAYl_EQ", "S5WA.F")];

pub(crate) enum TransactionImportOutcome {
    Ready(Transaction),
    Unresolvable(&'static str),
}

#[derive(Clone)]
pub(crate) struct ProviderTransactionImport {
    transaction: ProviderTransaction,
    account_id: Uuid,
    visibility: TransactionVisibilityDto,
    binding_id: Uuid,
}

impl ProviderTransactionImport {
    pub fn new(
        transaction: ProviderTransaction,
        account_id: Uuid,
        visibility: TransactionVisibilityDto,
        binding_id: Uuid,
    ) -> Self {
        Self {
            transaction,
            account_id,
            visibility,
            binding_id,
        }
    }

    pub fn external_id(&self) -> &str {
        &self.transaction.external_id
    }

    pub fn external_hash(&self) -> String {
        self.transaction.external_hash()
    }

    pub fn currency(&self) -> &str {
        &self.transaction.currency
    }

    pub fn instrument_isin(&self) -> Option<&str> {
        self.transaction
            .asset_identifier
            .as_ref()
            .and(self.transaction.isin.as_deref())
    }

    pub fn instrument_underlying_symbol(&self) -> Option<&str> {
        self.transaction
            .asset_identifier
            .as_ref()
            .and(self.transaction.underlying_symbol.as_deref())
    }

    pub fn is_trade(&self) -> bool {
        self.transaction.quantity.is_some() && self.transaction.asset_identifier.is_some()
    }

    pub fn amount(&self) -> Decimal {
        self.transaction.amount
    }

    pub fn date(&self) -> OffsetDateTime {
        self.transaction.date
    }

    pub fn instrument_ticker_candidates(&self) -> Vec<String> {
        let Some(provider_ticker) = self.transaction.asset_identifier.as_deref() else {
            return vec![];
        };

        if let Some((_, alias)) = TICKER_ALIASES
            .iter()
            .find(|(from, _)| *from == provider_ticker)
        {
            return vec![(*alias).to_string()];
        }

        let stripped = provider_ticker
            .strip_suffix("_EQ")
            .unwrap_or(provider_ticker);

        if let Some(base) = stripped.strip_suffix("_US") {
            return vec![format!("{base}.NASDAQ"), format!("{base}.NYSE")];
        }
        if let Some(base) = stripped.strip_suffix('l') {
            if !base.is_empty()
                && base
                    .chars()
                    .all(|c| c.is_ascii_uppercase() || c.is_ascii_digit() || c == '.')
            {
                return vec![format!("{base}.LSE")];
            }
        }
        // Asset data sometimes lists a US stock under the other US exchange (e.g. ETSY as `.NYSE`).
        if let Some(base) = stripped.strip_suffix(".NASDAQ") {
            return vec![stripped.to_string(), format!("{base}.NYSE")];
        }
        if let Some(base) = stripped.strip_suffix(".NYSE") {
            return vec![stripped.to_string(), format!("{base}.NASDAQ")];
        }
        vec![stripped.to_string()]
    }

    pub fn try_into_transaction(
        &self,
        user_id: Uuid,
        cash_asset_id: Option<i32>,
        instrument_asset_id: Option<i32>,
    ) -> anyhow::Result<TransactionImportOutcome> {
        match self.build_dto(cash_asset_id, instrument_asset_id) {
            Ok(dto) => {
                let mut entity = create_transaction_from_dto(dto, user_id)?;
                entity.set_connector_link(Some(ConnectorLinkMeta {
                    binding_id: self.binding_id,
                    external_id: self.transaction.external_id.clone(),
                    external_hash: self.external_hash(),
                }));
                Ok(TransactionImportOutcome::Ready(entity))
            }
            Err(reason) => Ok(TransactionImportOutcome::Unresolvable(reason)),
        }
    }

    fn build_dto(
        &self,
        cash_asset_id: Option<i32>,
        instrument_asset_id: Option<i32>,
    ) -> Result<TransactionDto, &'static str> {
        let tx = &self.transaction;
        let Some(cash_asset_id) = cash_asset_id else {
            return Err("currency has no matching asset");
        };

        let transaction_type = match (tx.quantity, tx.asset_identifier.as_deref()) {
            (Some(quantity), Some(_)) => {
                let Some(instrument_asset_id) = instrument_asset_id else {
                    return Err("instrument has no matching asset");
                };
                if quantity.is_zero() {
                    return Err("zero-quantity trade");
                }
                if quantity.is_sign_positive() {
                    TransactionTypeDto::AssetPurchase(AssetPurchaseMetadataDto {
                        purchase: EntryDto::new(instrument_asset_id, self.account_id, quantity),
                        sale: EntryDto::new(cash_asset_id, self.account_id, tx.amount),
                    })
                } else {
                    TransactionTypeDto::AssetSale(AssetSaleMetadataDto {
                        sale: EntryDto::new(instrument_asset_id, self.account_id, quantity),
                        proceeds: EntryDto::new(cash_asset_id, self.account_id, tx.amount),
                    })
                }
            }
            // TODO: import dividend reversals; a Cash Dividend can't hold a negative amount.
            (None, Some(_)) if tx.amount.is_sign_negative() => {
                return Err("negative dividend (reversal) is not supported");
            }
            (None, Some(_)) => {
                let Some(instrument_asset_id) = instrument_asset_id else {
                    return Err("dividend origin has no matching asset");
                };
                TransactionTypeDto::CashDividend(CashDividendMetadataDto {
                    entry: EntryDto::new(cash_asset_id, self.account_id, tx.amount),
                    origin_asset_id: instrument_asset_id,
                })
            }
            (Some(_), None) => return Err("quantity without instrument identifier"),
            (None, None) => TransactionTypeDto::Regular(RegularTransactionMetadataDto {
                description: Some(tx.description.clone()),
                entry: EntryDto::new(cash_asset_id, self.account_id, tx.amount),
                category_id: IMPORT_CATEGORY_ID,
            }),
        };

        Ok(TransactionDto {
            transaction_id: None,
            date: tx.date,
            visibility: self.visibility,
            fee_entries: vec![],
            transaction_type,
        })
    }
}
