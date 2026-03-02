package br.com.logdash.backoffice_backend.delivery.domain.event;

import br.com.logdash.backoffice_backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class DeliveryAssignedEvent extends DomainEvent {
    private final Long deliveryId;
    private final Long orderId;
    private final Long courierId;
    private final String courierName;

    public DeliveryAssignedEvent(Long deliveryId, Long orderId, Long courierId, String courierName) {
        super();
        this.deliveryId = deliveryId;
        this.orderId = orderId;
        this.courierId = courierId;
        this.courierName = courierName;
    }
}
