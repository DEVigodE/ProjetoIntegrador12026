package br.com.logdash.backend.orders.presentation.controller;

import br.com.logdash.backend.orders.application.dto.*;
import br.com.logdash.backend.orders.application.service.OrderApplicationService;
import br.com.logdash.backend.orders.domain.valueobject.OrderStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
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
            @ParameterObject Pageable pageable,
            Authentication authentication) {
        if (authentication != null && isClient(authentication)) {
            return orderService.listOrdersForCustomer(authentication.getName(), status, pageable);
        }
        return orderService.listOrders(status, pageable);
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public Page<OrderResponse> listMyOrders(
            @RequestParam(required = false) OrderStatus status,
            @ParameterObject Pageable pageable,
            Authentication authentication) {
        return orderService.listOrdersForCustomer(authentication.getName(), status, pageable);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR') or (hasRole('CLIENT') and @orderSecurity.isOwner(#id, authentication))")
    public OrderResponse getOrder(@PathVariable Long id) {
        return orderService.getOrder(id);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR', 'CLIENT')")
    public ResponseEntity<OrderResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request,
            Authentication authentication) {
        String customerId = isClient(authentication) ? authentication.getName() : null;
        return ResponseEntity.status(201).body(orderService.createOrder(request, customerId));
    }

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public Page<OrderResponse> getActiveOrders(@ParameterObject Pageable pageable) {
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

    private boolean isClient(Authentication authentication) {
        return authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_CLIENT"));
    }
}
