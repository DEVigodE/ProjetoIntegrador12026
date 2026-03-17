package br.com.logdash.backend.delivery.infrastructure.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class DeliveryEventListener {
    // Delivery context currently publishes events but does not consume cross-context events
    // DeliveryAssignedEvent and DeliveryCompletedEvent are consumed by Orders and Communication contexts
}
