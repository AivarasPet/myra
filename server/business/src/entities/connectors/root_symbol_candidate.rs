use dal::models::asset_models::AssetRootSymbolCandidate;

/// Holdings win: a single candidate held in the account, else a single one held anywhere by
/// the user. When the user holds several, only one quoted in `currency` qualifies; lower tiers
/// are not consulted. Without holdings, the single candidate quoted in `currency` wins.
pub(crate) fn select_root_symbol_candidate(
    candidates: &[AssetRootSymbolCandidate],
    currency: &str,
) -> Option<i32> {
    fn single<'a>(mut matches: impl Iterator<Item = &'a AssetRootSymbolCandidate>) -> Option<i32> {
        match (matches.next(), matches.next()) {
            (Some(only), None) => Some(only.id),
            _ => None,
        }
    }

    let quoted_in_currency = |candidate: &&AssetRootSymbolCandidate| {
        candidate
            .base_currency
            .as_deref()
            .is_some_and(|base| base.eq_ignore_ascii_case(currency))
    };

    for held in [
        candidates
            .iter()
            .filter(|c| c.held_in_account)
            .collect::<Vec<_>>(),
        candidates
            .iter()
            .filter(|c| c.held_by_user)
            .collect::<Vec<_>>(),
    ] {
        match held.as_slice() {
            [] => continue,
            [only] => return Some(only.id),
            _ => return single(held.into_iter().filter(quoted_in_currency)),
        }
    }
    single(candidates.iter().filter(quoted_in_currency))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn candidate(
        id: i32,
        base_currency: &str,
        held_in_account: bool,
        held_by_user: bool,
    ) -> AssetRootSymbolCandidate {
        AssetRootSymbolCandidate {
            id,
            root_symbol: "shell".to_string(),
            base_currency: Some(base_currency.to_string()),
            held_in_account,
            held_by_user,
        }
    }

    #[test]
    fn prefers_asset_held_in_account() {
        let candidates = [
            candidate(1, "EUR", false, true),
            candidate(2, "GBP", true, true),
            candidate(3, "EUR", false, false),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "EUR"), Some(2));
    }

    #[test]
    fn falls_back_to_asset_held_in_other_account() {
        let candidates = [
            candidate(1, "CZK", false, true),
            candidate(2, "EUR", false, false),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "EUR"), Some(1));
    }

    #[test]
    fn narrows_several_holdings_by_currency() {
        let candidates = [
            candidate(1, "CZK", true, true),
            candidate(2, "EUR", true, true),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "eur"), Some(2));
    }

    #[test]
    fn ambiguous_holdings_do_not_fall_through_to_unheld_assets() {
        let candidates = [
            candidate(1, "CZK", true, true),
            candidate(2, "GBP", true, true),
            candidate(3, "EUR", false, false),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "EUR"), None);
    }

    #[test]
    fn picks_unheld_asset_quoted_in_transaction_currency() {
        let candidates = [
            candidate(1, "CZK", false, false),
            candidate(2, "EUR", false, false),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "EUR"), Some(2));
    }

    #[test]
    fn leaves_ambiguous_or_unmatched_currency_unresolved() {
        let candidates = [
            candidate(1, "EUR", false, false),
            candidate(2, "EUR", false, false),
            candidate(3, "CZK", false, false),
        ];
        assert_eq!(select_root_symbol_candidate(&candidates, "EUR"), None);
        assert_eq!(select_root_symbol_candidate(&candidates, "USD"), None);
    }
}
