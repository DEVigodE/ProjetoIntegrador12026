CREATE SCHEMA IF NOT EXISTS delivery_schema;

CREATE TABLE delivery_schema.couriers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE,
    vehicle_type VARCHAR(50),
    vehicle_plate VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE delivery_schema.deliveries (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    courier_id BIGINT REFERENCES delivery_schema.couriers(id),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    assigned_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
