package br.com.logdash.backoffice_backend.orders.domain.event;

import br.com.logdash.backoffice_backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class OrderCreatedEvent extends DomainEvent {

    private final Long orderId;
    private final String customerName;

    public OrderCreatedEvent(Long orderId, String customerName) {
        super();
        this.orderId = orderId;
        this.customerName = customerName;
    }
}
