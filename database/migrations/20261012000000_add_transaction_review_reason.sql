ALTER TABLE transaction
    ADD COLUMN review_reason TEXT CHECK (review_reason IN ('auto_opening_buy'));

CREATE INDEX IF NOT EXISTS idx_transaction_review_reason
    ON transaction (user_id, date_transacted)
    WHERE review_reason IS NOT NULL;
