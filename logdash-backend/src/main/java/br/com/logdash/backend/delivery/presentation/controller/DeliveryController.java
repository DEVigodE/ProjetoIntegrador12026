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
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springdoc.core.annotations.ParameterObject;

import java.util.Map;
import java.util.Optional;

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

    // ---- Endpoints para entregador (COURIER) ----

    @GetMapping("/my-active")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DeliveryResponse> getMyActiveDelivery(Authentication authentication) {
        Optional<DeliveryResponse> delivery = deliveryService.getMyActiveDelivery(authentication.getName());
        return delivery.map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }

    @PostMapping("/self-assign")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DeliveryResponse> selfAssign(
            @RequestBody Map<String, Long> body,
            Authentication authentication) {
        return ResponseEntity.status(201)
                .body(deliveryService.selfAssign(body.get("orderId"), authentication.getName()));
    }

    @PatchMapping("/{id}/pickup")
    @PreAuthorize("isAuthenticated()")
    public DeliveryResponse markPickedUp(
            @PathVariable Long id,
            Authentication authentication) {
        return deliveryService.markPickedUp(id, authentication.getName());
    }

    @PatchMapping("/{id}/complete")
    @PreAuthorize("isAuthenticated()")
    public DeliveryResponse completeDelivery(
            @PathVariable Long id,
            Authentication authentication) {
        return deliveryService.completeDelivery(id, authentication.getName());
    }
}
