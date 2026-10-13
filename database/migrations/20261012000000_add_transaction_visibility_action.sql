ALTER TABLE transaction DROP CONSTRAINT transaction_visibility_check;

ALTER TABLE transaction
    ADD CONSTRAINT transaction_visibility_check
    CHECK (visibility IN ('default', 'ghost', 'hidden', 'action'));
