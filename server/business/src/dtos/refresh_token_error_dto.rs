#[derive(Debug, thiserror::Error)]
pub enum RefreshTokenError {
    #[error("Invalid refresh token")]
    Invalid,
    #[error("Refresh token expired")]
    Expired,
}
