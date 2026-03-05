CREATE SCHEMA IF NOT EXISTS orders_schema;

CREATE TABLE orders_schema.orders (
    id BIGSERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    delivery_street VARCHAR(255),
    delivery_number VARCHAR(20),
    delivery_complement VARCHAR(100),
    delivery_neighborhood VARCHAR(100),
    delivery_city VARCHAR(100),
    delivery_state VARCHAR(2),
    delivery_zip_code VARCHAR(10),
    total_amount DECIMAL(10,2) NOT NULL,
    notes TEXT,
    rejected_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE orders_schema.order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders_schema.orders(id),
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10,2) NOT NULL,
    notes TEXT
);
