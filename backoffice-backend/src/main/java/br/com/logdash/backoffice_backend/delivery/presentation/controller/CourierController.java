package br.com.logdash.backoffice_backend.delivery.presentation.controller;

import br.com.logdash.backoffice_backend.delivery.application.dto.CourierRequest;
import br.com.logdash.backoffice_backend.delivery.application.dto.CourierResponse;
import br.com.logdash.backoffice_backend.delivery.application.service.DeliveryApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springdoc.core.annotations.ParameterObject;

import java.util.List;

@RestController
@RequestMapping("/api/couriers")
@RequiredArgsConstructor
public class CourierController {

    private final DeliveryApplicationService deliveryService;

    @GetMapping
    public Page<CourierResponse> listCouriers(@ParameterObject Pageable pageable) {
        return deliveryService.listCouriers(pageable);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public ResponseEntity<CourierResponse> createCourier(@Valid @RequestBody CourierRequest request) {
        return ResponseEntity.status(201).body(deliveryService.createCourier(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public CourierResponse updateCourier(@PathVariable Long id, @Valid @RequestBody CourierRequest request) {
        return deliveryService.updateCourier(id, request);
    }

    @PatchMapping("/{id}/activate")
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public CourierResponse activateCourier(@PathVariable Long id) {
        return deliveryService.activateCourier(id);
    }

    @PatchMapping("/{id}/deactivate")
    @PreAuthorize("hasAnyRole('ADMIN', 'DISPATCHER')")
    public CourierResponse deactivateCourier(@PathVariable Long id) {
        return deliveryService.deactivateCourier(id);
    }

    @GetMapping("/available")
    public List<CourierResponse> getAvailableCouriers() {
        return deliveryService.getAvailableCouriers();
    }
}
