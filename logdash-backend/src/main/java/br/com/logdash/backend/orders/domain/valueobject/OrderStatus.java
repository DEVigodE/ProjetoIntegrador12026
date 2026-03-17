package br.com.logdash.backend.orders.domain.valueobject;

public enum OrderStatus {
    PENDING,
    ACCEPTED,
    PREPARING,
    READY,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCELLED
}
