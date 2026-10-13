#[cfg(feature = "backend")]
use business::dtos::transaction_dto::ReviewReasonDto;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// Why a transaction needs the user's review.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum ReviewReason {
    /// Created by a sync to cover a sell of shares the synced history never bought; its date and
    /// price are placeholders.
    AutoOpeningBuy,
}

#[cfg(feature = "backend")]
impl From<ReviewReasonDto> for ReviewReason {
    fn from(value: ReviewReasonDto) -> Self {
        match value {
            ReviewReasonDto::AutoOpeningBuy => Self::AutoOpeningBuy,
        }
    }
}
