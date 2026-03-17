CREATE SCHEMA IF NOT EXISTS communication_schema;

CREATE TABLE communication_schema.chat_channels (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE communication_schema.chat_participants (
    id BIGSERIAL PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES communication_schema.chat_channels(id),
    participant_id VARCHAR(255) NOT NULL,
    participant_type VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE communication_schema.messages (
    id BIGSERIAL PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES communication_schema.chat_channels(id),
    order_id BIGINT NOT NULL,
    sender_id VARCHAR(255) NOT NULL,
    sender_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT NOW(),
    read_at TIMESTAMP
);

CREATE INDEX idx_messages_channel_id ON communication_schema.messages(channel_id);
CREATE INDEX idx_messages_order_id ON communication_schema.messages(order_id);
CREATE INDEX idx_messages_sent_at ON communication_schema.messages(sent_at);
