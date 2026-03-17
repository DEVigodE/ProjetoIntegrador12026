package br.com.logdash.backend.delivery.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class DeliveryCompletedEvent extends DomainEvent {
    private final Long deliveryId;
    private final Long orderId;

    public DeliveryCompletedEvent(Long deliveryId, Long orderId) {
        super();
        this.deliveryId = deliveryId;
        this.orderId = orderId;
    }
}
