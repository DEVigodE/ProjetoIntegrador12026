package br.com.logdash.backoffice_backend.orders.presentation.controller;

import br.com.logdash.backoffice_backend.orders.application.dto.*;
import br.com.logdash.backoffice_backend.orders.application.service.OrderApplicationService;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderApplicationService orderService;

    @GetMapping
    public Page<OrderResponse> listOrders(
            @RequestParam(required = false) OrderStatus status,
            Pageable pageable) {
        return orderService.listOrders(status, pageable);
    }

    @GetMapping("/{id}")
    public OrderResponse getOrder(@PathVariable Long id) {
        return orderService.getOrder(id);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        return ResponseEntity.status(201).body(orderService.createOrder(request));
    }

    @GetMapping("/active")
    public Page<OrderResponse> getActiveOrders(Pageable pageable) {
        return orderService.getActiveOrders(pageable);
    }

    @PatchMapping("/{id}/accept")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<Void> acceptOrder(@PathVariable Long id) {
        orderService.acceptOrder(id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<Void> rejectOrder(
            @PathVariable Long id,
            @Valid @RequestBody RejectOrderRequest request) {
        orderService.rejectOrder(id, request);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<Void> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        OrderStatus newStatus = OrderStatus.valueOf(body.get("status"));
        orderService.updateStatus(id, newStatus);
        return ResponseEntity.ok().build();
    }
}
