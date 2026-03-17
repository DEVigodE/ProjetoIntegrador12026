package br.com.logdash.backend.orders.infrastructure.listener;

import br.com.logdash.backend.delivery.domain.event.DeliveryCompletedEvent;
import br.com.logdash.backend.orders.domain.model.Order;
import br.com.logdash.backend.orders.domain.repository.OrderRepository;
import br.com.logdash.backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
@Slf4j
public class OrderEventListener {

    private final OrderRepository orderRepository;

    @EventListener
    @Transactional
    public void handleDeliveryCompleted(DeliveryCompletedEvent event) {
        log.info("Entrega concluída - marcando pedido {} como entregue", event.getOrderId());
        Order order = orderRepository.findById(event.getOrderId())
                .orElseThrow(() -> new ResourceNotFoundException("Pedido não encontrado: " + event.getOrderId()));
        order.markAsDelivered();
        orderRepository.save(order);
    }
}
