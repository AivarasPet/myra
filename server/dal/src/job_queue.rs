use apalis::prelude::TaskSink;
use apalis_postgres::PostgresStorage;
use serde::{de::DeserializeOwned, Serialize};
use sqlx::PgPool;

use crate::database_context::MyraDb;

#[derive(Clone)]
pub struct JobQueueHandle {
    pool: PgPool,
    db: Option<MyraDb>,
}

impl JobQueueHandle {
    pub fn new(pool: PgPool) -> Self {
        Self { pool, db: None }
    }

    /// A handle whose pushes wait for `db`'s open transaction to commit, so a worker never
    /// picks up a job about rows it cannot see yet, or that a rollback removed.
    pub fn bound_to(&self, db: MyraDb) -> Self {
        Self {
            pool: self.pool.clone(),
            db: Some(db),
        }
    }

    pub async fn run_migrations(pool: &PgPool) -> anyhow::Result<()> {
        let mut migrator = PostgresStorage::<(), (), ()>::migrations();
        migrator.set_ignore_missing(true);
        migrator.run(pool).await?;
        Ok(())
    }

    #[tracing::instrument(level = "debug", skip_all)]
    pub async fn push<T>(&self, job: T) -> anyhow::Result<()>
    where
        T: Serialize + DeserializeOwned + Send + Sync + Unpin + 'static,
    {
        let pool = self.pool.clone();
        let push = move || -> std::pin::Pin<Box<dyn std::future::Future<Output = anyhow::Result<()>> + Send>> {
            Box::pin(async move {
                let mut storage = PostgresStorage::<T>::new(&pool);
                storage.push(job).await?;
                Ok(())
            })
        };
        match &self.db {
            Some(db) => db.run_after_commit(Box::new(push)).await,
            None => push().await,
        }
    }
}
