package br.com.logdash.backoffice_backend.orders.domain.valueobject;

public enum OrderStatus {
    PENDING,
    ACCEPTED,
    PREPARING,
    READY,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCELLED
}
