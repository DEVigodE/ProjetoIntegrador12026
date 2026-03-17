package br.com.logdash.backend.catalog.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class StockChangedEvent extends DomainEvent {

    private final Long productId;
    private final int previousQuantity;
    private final int newQuantity;

    public StockChangedEvent(Long productId, int previousQuantity, int newQuantity) {
        super();
        this.productId = productId;
        this.previousQuantity = previousQuantity;
        this.newQuantity = newQuantity;
    }
}
