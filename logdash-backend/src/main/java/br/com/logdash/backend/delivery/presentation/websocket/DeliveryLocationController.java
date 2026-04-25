package br.com.logdash.backend.delivery.presentation.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.time.Instant;

/**
 * Controller WebSocket/STOMP para atualizações de geolocalização do entregador.
 *
 * Fluxo:
 *   Entregador publica em:  /app/delivery/{deliveryId}/location
 *   Operadores subscrevem:  /topic/delivery/{deliveryId}/location
 *   Clientes subscrevem:    /topic/order/{orderId}/location
 *
 * Payload esperado: LocationUpdateMessage (courierId, deliveryId, orderId, latitude, longitude, status)
 */
@Controller
@RequiredArgsConstructor
public class DeliveryLocationController {

    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/delivery/{deliveryId}/location")
    @SendTo("/topic/delivery/{deliveryId}/location")
    public LocationUpdateMessage broadcastLocation(
            @DestinationVariable Long deliveryId,
            LocationUpdateMessage message) {
        message.setDeliveryId(deliveryId);
        if (message.getTimestamp() == null) {
            message.setTimestamp(Instant.now());
        }
        if (message.getOrderId() != null) {
            messagingTemplate.convertAndSend(
                    "/topic/order/" + message.getOrderId() + "/location", message);
        }
        return message;
    }
}
