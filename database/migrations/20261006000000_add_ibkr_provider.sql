INSERT INTO connector_provider (kind, display_name) VALUES
    ('ibkr', 'Interactive Brokers')
ON CONFLICT (kind) DO NOTHING;
