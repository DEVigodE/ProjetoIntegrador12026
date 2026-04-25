package br.com.logdash.backend.delivery.presentation.websocket;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LocationUpdateMessage {

    private String courierId;
    private Long deliveryId;
    private Long orderId;
    private Instant timestamp;
    private double latitude;
    private double longitude;
    private String status;
}
