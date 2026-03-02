package br.com.logdash.backoffice_backend.orders.domain.event;

import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backoffice_backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class OrderStatusChangedEvent extends DomainEvent {

    private final Long orderId;
    private final OrderStatus previousStatus;
    private final OrderStatus newStatus;

    public OrderStatusChangedEvent(Long orderId, OrderStatus previousStatus, OrderStatus newStatus) {
        super();
        this.orderId = orderId;
        this.previousStatus = previousStatus;
        this.newStatus = newStatus;
    }
}
