package br.com.logdash.backend.orders.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class OrderRejectedEvent extends DomainEvent {

    private final Long orderId;
    private final String reason;

    public OrderRejectedEvent(Long orderId, String reason) {
        super();
        this.orderId = orderId;
        this.reason = reason;
    }
}
