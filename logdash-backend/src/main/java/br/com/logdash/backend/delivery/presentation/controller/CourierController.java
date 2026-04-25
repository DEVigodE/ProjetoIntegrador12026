package br.com.logdash.backend.delivery.presentation.controller;

import br.com.logdash.backend.delivery.application.dto.CourierRequest;
import br.com.logdash.backend.delivery.application.dto.CourierResponse;
import br.com.logdash.backend.delivery.application.dto.CourierSelfRegisterRequest;
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

    // ---- Auto-cadastro do entregador ----

    /**
     * Retorna o perfil do entregador autenticado.
     * HTTP 200 → perfil existe; HTTP 404 → ainda não cadastrado (precisa chamar POST /me).
     */
    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CourierResponse> getMyCourierProfile(Authentication authentication) {
        return deliveryService.getMyCourierProfile(authentication.getName())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Cria (ou retorna existente) o perfil do entregador vinculado ao JWT atual.
     * O entregador preenche nome, telefone e veículo — o keycloakId vem do JWT.
     */
    @PostMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CourierResponse> selfRegister(
            @Valid @RequestBody CourierSelfRegisterRequest request,
            Authentication authentication) {
        return ResponseEntity.status(201)
                .body(deliveryService.selfRegister(authentication.getName(), request));
    }
}
