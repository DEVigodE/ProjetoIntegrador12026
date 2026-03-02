package br.com.logdash.backoffice_backend.delivery.domain.event;

import br.com.logdash.backoffice_backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class CourierRegisteredEvent extends DomainEvent {
    private final Long courierId;
    private final String courierName;

    public CourierRegisteredEvent(Long courierId, String courierName) {
        super();
        this.courierId = courierId;
        this.courierName = courierName;
    }
}
