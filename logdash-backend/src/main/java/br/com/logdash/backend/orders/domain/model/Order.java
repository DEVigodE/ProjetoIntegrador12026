package br.com.logdash.backend.orders.domain.model;

import br.com.logdash.backend.orders.domain.event.*;
import br.com.logdash.backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.AbstractAggregateRoot;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Table(name = "orders", schema = "orders_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Order extends AbstractAggregateRoot<Order> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private OrderStatus status;

    @Column(name = "customer_name", nullable = false)
    private String customerName;

    @Column(name = "customer_phone", nullable = false, length = 20)
    private String customerPhone;

    @Column(name = "customer_email")
    private String customerEmail;

    @Column(name = "delivery_street")
    private String deliveryStreet;

    @Column(name = "delivery_number", length = 20)
    private String deliveryNumber;

    @Column(name = "delivery_complement", length = 100)
    private String deliveryComplement;

    @Column(name = "delivery_neighborhood", length = 100)
    private String deliveryNeighborhood;

    @Column(name = "delivery_city", length = 100)
    private String deliveryCity;

    @Column(name = "delivery_state", length = 2)
    private String deliveryState;

    @Column(name = "delivery_zip_code", length = 10)
    private String deliveryZipCode;

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "rejected_reason", columnDefinition = "TEXT")
    private String rejectedReason;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    public static Order create(String customerName, String customerPhone, String customerEmail,
                                String deliveryStreet, String deliveryNumber, String deliveryComplement,
                                String deliveryNeighborhood, String deliveryCity, String deliveryState,
                                String deliveryZipCode, String notes) {
        Order order = new Order();
        order.status = OrderStatus.PENDING;
        order.customerName = customerName;
        order.customerPhone = customerPhone;
        order.customerEmail = customerEmail;
        order.deliveryStreet = deliveryStreet;
        order.deliveryNumber = deliveryNumber;
        order.deliveryComplement = deliveryComplement;
        order.deliveryNeighborhood = deliveryNeighborhood;
        order.deliveryCity = deliveryCity;
        order.deliveryState = deliveryState;
        order.deliveryZipCode = deliveryZipCode;
        order.notes = notes;
        order.totalAmount = BigDecimal.ZERO;
        order.createdAt = LocalDateTime.now();
        order.updatedAt = LocalDateTime.now();
        return order;
    }

    public void addItem(Long productId, String productName, BigDecimal unitPrice, int quantity, String notes) {
        OrderItem item = OrderItem.create(this, productId, productName, unitPrice, quantity, notes);
        this.items.add(item);
        recalculateTotal();
    }

    private void recalculateTotal() {
        this.totalAmount = items.stream()
                .map(OrderItem::getSubtotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        this.updatedAt = LocalDateTime.now();
    }

    public void markAsCreated() {
        registerEvent(new OrderCreatedEvent(this.id, this.customerName));
    }

    public void accept() {
        if (this.status != OrderStatus.PENDING) {
            throw new InvalidStateException("Pedido não está pendente");
        }
        OrderStatus previous = this.status;
        this.status = OrderStatus.ACCEPTED;
        this.updatedAt = LocalDateTime.now();

        List<OrderAcceptedEvent.OrderItemInfo> itemInfos = this.items.stream()
                .map(item -> new OrderAcceptedEvent.OrderItemInfo(item.getProductId(), item.getQuantity()))
                .collect(Collectors.toList());
        registerEvent(new OrderAcceptedEvent(this.id, itemInfos));
        registerEvent(new OrderStatusChangedEvent(this.id, previous, this.status));
    }

    public void reject(String reason) {
        if (this.status != OrderStatus.PENDING) {
            throw new InvalidStateException("Pedido não pode ser recusado");
        }
        OrderStatus previous = this.status;
        this.status = OrderStatus.CANCELLED;
        this.rejectedReason = reason;
        this.updatedAt = LocalDateTime.now();
        registerEvent(new OrderRejectedEvent(this.id, reason));
        registerEvent(new OrderStatusChangedEvent(this.id, previous, this.status));
    }

    public void updateStatus(OrderStatus newStatus) {
        validateStatusTransition(newStatus);
        OrderStatus previous = this.status;
        this.status = newStatus;
        this.updatedAt = LocalDateTime.now();
        registerEvent(new OrderStatusChangedEvent(this.id, previous, newStatus));
    }

    public void markAsDelivered() {
        if (this.status != OrderStatus.OUT_FOR_DELIVERY) {
            throw new InvalidStateException("Pedido não está em rota de entrega");
        }
        OrderStatus previous = this.status;
        this.status = OrderStatus.DELIVERED;
        this.updatedAt = LocalDateTime.now();
        registerEvent(new OrderStatusChangedEvent(this.id, previous, this.status));
    }

    private void validateStatusTransition(OrderStatus newStatus) {
        boolean valid = switch (this.status) {
            case PENDING -> newStatus == OrderStatus.ACCEPTED || newStatus == OrderStatus.CANCELLED;
            case ACCEPTED -> newStatus == OrderStatus.PREPARING || newStatus == OrderStatus.CANCELLED;
            case PREPARING -> newStatus == OrderStatus.READY || newStatus == OrderStatus.CANCELLED;
            case READY -> newStatus == OrderStatus.OUT_FOR_DELIVERY || newStatus == OrderStatus.CANCELLED;
            case OUT_FOR_DELIVERY -> newStatus == OrderStatus.DELIVERED;
            case DELIVERED, CANCELLED -> false;
        };
        if (!valid) {
            throw new InvalidStateException(
                    String.format("Transição inválida de %s para %s", this.status, newStatus));
        }
    }

    public boolean isActive() {
        return this.status != OrderStatus.DELIVERED && this.status != OrderStatus.CANCELLED;
    }
}
