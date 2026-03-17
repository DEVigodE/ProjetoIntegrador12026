package br.com.logdash.backend.catalog.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class ProductCreatedEvent extends DomainEvent {

    private final Long productId;
    private final String productName;

    public ProductCreatedEvent(Long productId, String productName) {
        super();
        this.productId = productId;
        this.productName = productName;
    }
}
