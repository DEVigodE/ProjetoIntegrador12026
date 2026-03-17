package br.com.logdash.backend.delivery.presentation.controller;

import br.com.logdash.backend.delivery.application.dto.CreateDeliveryRequest;
import br.com.logdash.backend.delivery.application.dto.DeliveryResponse;
import br.com.logdash.backend.delivery.application.service.DeliveryApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springdoc.core.annotations.ParameterObject;

import java.util.Map;

@RestController
@RequestMapping("/api/deliveries")
@RequiredArgsConstructor
public class DeliveryController {

    private final DeliveryApplicationService deliveryService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public ResponseEntity<DeliveryResponse> createDelivery(@Valid @RequestBody CreateDeliveryRequest request) {
        return ResponseEntity.status(201).body(deliveryService.createDelivery(request));
    }

    @PatchMapping("/{id}/assign")
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public DeliveryResponse assignCourier(
            @PathVariable Long id,
            @RequestBody Map<String, Long> body) {
        return deliveryService.assignCourier(id, body.get("courierId"));
    }

    @GetMapping("/active")
    public Page<DeliveryResponse> getActiveDeliveries(@ParameterObject Pageable pageable) {
        return deliveryService.getActiveDeliveries(pageable);
    }
}
