package br.com.logdash.backend.communication.infrastructure.listener;

import br.com.logdash.backend.communication.application.service.ChatApplicationService;
import br.com.logdash.backend.delivery.domain.event.DeliveryAssignedEvent;
import br.com.logdash.backend.orders.domain.event.OrderAcceptedEvent;
import br.com.logdash.backend.orders.domain.event.OrderCreatedEvent;
import br.com.logdash.backend.orders.domain.event.OrderStatusChangedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
@Slf4j
public class CommunicationEventListener {

    private final ChatApplicationService chatApplicationService;

    @EventListener
    @Transactional
    public void handleOrderCreated(OrderCreatedEvent event) {
        log.info("Pedido criado - criando canal de chat para pedido {}", event.getOrderId());
        chatApplicationService.createChannel(event.getOrderId());
    }

    @EventListener
    @Transactional
    public void handleOrderAccepted(OrderAcceptedEvent event) {
        log.info("Pedido aceito - enviando mensagem automática no chat do pedido {}", event.getOrderId());
        chatApplicationService.sendSystemMessage(event.getOrderId(),
                "Pedido #" + event.getOrderId() + " foi aceito! Estamos preparando.");
    }

    @EventListener
    @Transactional
    public void handleOrderStatusChanged(OrderStatusChangedEvent event) {
        log.info("Status do pedido {} alterado de {} para {}", event.getOrderId(),
                event.getPreviousStatus(), event.getNewStatus());
        chatApplicationService.sendSystemMessage(event.getOrderId(),
                "Status do pedido atualizado para: " + event.getNewStatus());
    }

    @EventListener
    @Transactional
    public void handleDeliveryAssigned(DeliveryAssignedEvent event) {
        log.info("Entregador {} atribuído ao pedido {}", event.getCourierName(), event.getOrderId());
        chatApplicationService.sendSystemMessage(event.getOrderId(),
                "Entregador " + event.getCourierName() + " foi atribuído à sua entrega.");
    }
}
