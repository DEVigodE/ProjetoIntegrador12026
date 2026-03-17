package br.com.logdash.backend.catalog.infrastructure.listener;

import br.com.logdash.backend.catalog.domain.service.ProductDomainService;
import br.com.logdash.backend.orders.domain.event.OrderAcceptedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
@Slf4j
public class CatalogEventListener {

    private final ProductDomainService productDomainService;

    @EventListener
    @Transactional
    public void handleOrderAccepted(OrderAcceptedEvent event) {
        log.info("Pedido aceito - decrementando estoque para os itens do pedido {}", event.getOrderId());
        event.getItems().forEach(item ->
                productDomainService.decrementStock(item.getProductId(), item.getQuantity())
        );
    }
}
