ALTER TABLE orders_schema.orders ADD COLUMN customer_id VARCHAR(255);

CREATE INDEX idx_orders_customer_id ON orders_schema.orders(customer_id);
