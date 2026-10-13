use ai::models::error::AiError;
use async_trait::async_trait;
use business::dtos::conflict_error_dto::BusinessConflictError;
use business::jobs::SyncConnectorBindingJob;
use business::service_collection::connector_sync_service::ConnectorSyncService;
use business::service_collection::ServiceProviders;
use time::OffsetDateTime;

use crate::jobs::WorkerJob;
use crate::retry::{self, RetryDecision, RetryPolicy};

#[async_trait]
impl WorkerJob for SyncConnectorBindingJob {
    const NAME: &'static str = "sync_connector_binding";

    fn retry_policy() -> RetryPolicy {
        RetryPolicy::standard()
    }

    /// A held provider-account claim (another sync running) is a retryable conflict: the retry
    /// is what runs a "sync now" pressed during a short sync right after it. Other failures come
    /// from the provider or the projection and keep the default transient retry.
    fn classify_error(error: &anyhow::Error) -> AiError {
        if error.downcast_ref::<BusinessConflictError>().is_some() {
            AiError::ConcurrencyLimited
        } else {
            AiError::ProviderUnavailable {
                detail: format!("{error:#}"),
            }
        }
    }

    #[tracing::instrument(level = "info", skip_all, fields(binding_id = %self.binding_id, user_id = %self.user_id))]
    async fn run(&self, providers: &ServiceProviders) -> anyhow::Result<()> {
        let sync_svc = ConnectorSyncService::new(providers);
        sync_svc.sync_binding(self.user_id, self.binding_id).await?;
        Ok(())
    }

    fn decide(error: &anyhow::Error, attempts: i32) -> RetryDecision {
        retry::decide(
            &Self::classify_error(error).retry_class(),
            attempts,
            &Self::retry_policy(),
            OffsetDateTime::now_utc(),
            retry::random_global_jitter(),
        )
    }
}
