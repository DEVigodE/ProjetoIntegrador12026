package br.com.logdash.backoffice_backend.orders.application.dto;

import br.com.logdash.backoffice_backend.orders.domain.model.Order;
import br.com.logdash.backoffice_backend.orders.domain.model.OrderItem;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {

    private Long id;
    private OrderStatus status;
    private String customerName;
    private String customerPhone;
    private String customerEmail;
    private String deliveryStreet;
    private String deliveryNumber;
    private String deliveryComplement;
    private String deliveryNeighborhood;
    private String deliveryCity;
    private String deliveryState;
    private String deliveryZipCode;
    private BigDecimal totalAmount;
    private String notes;
    private String rejectedReason;
    private List<OrderItemResponse> items;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static OrderResponse from(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .status(order.getStatus())
                .customerName(order.getCustomerName())
                .customerPhone(order.getCustomerPhone())
                .customerEmail(order.getCustomerEmail())
                .deliveryStreet(order.getDeliveryStreet())
                .deliveryNumber(order.getDeliveryNumber())
                .deliveryComplement(order.getDeliveryComplement())
                .deliveryNeighborhood(order.getDeliveryNeighborhood())
                .deliveryCity(order.getDeliveryCity())
                .deliveryState(order.getDeliveryState())
                .deliveryZipCode(order.getDeliveryZipCode())
                .totalAmount(order.getTotalAmount())
                .notes(order.getNotes())
                .rejectedReason(order.getRejectedReason())
                .items(order.getItems().stream().map(OrderItemResponse::from).collect(Collectors.toList()))
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .build();
    }

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemResponse {
        private Long id;
        private Long productId;
        private String productName;
        private BigDecimal unitPrice;
        private int quantity;
        private BigDecimal subtotal;
        private String notes;

        public static OrderItemResponse from(OrderItem item) {
            return OrderItemResponse.builder()
                    .id(item.getId())
                    .productId(item.getProductId())
                    .productName(item.getProductName())
                    .unitPrice(item.getUnitPrice())
                    .quantity(item.getQuantity())
                    .subtotal(item.getSubtotal())
                    .notes(item.getNotes())
                    .build();
        }
    }
}
