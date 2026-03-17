package br.com.logdash.backend.orders.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

import java.util.List;

@Getter
public class OrderAcceptedEvent extends DomainEvent {

    private final Long orderId;
    private final List<OrderItemInfo> items;

    public OrderAcceptedEvent(Long orderId, List<OrderItemInfo> items) {
        super();
        this.orderId = orderId;
        this.items = items;
    }

    @Getter
    public static class OrderItemInfo {
        private final Long productId;
        private final int quantity;

        public OrderItemInfo(Long productId, int quantity) {
            this.productId = productId;
            this.quantity = quantity;
        }
    }
}
