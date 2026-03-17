package br.com.logdash.backend.delivery.domain.model;

import br.com.logdash.backend.delivery.domain.event.DeliveryAssignedEvent;
import br.com.logdash.backend.delivery.domain.event.DeliveryCompletedEvent;
import br.com.logdash.backend.delivery.domain.valueobject.DeliveryStatus;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.AbstractAggregateRoot;

import java.time.LocalDateTime;

@Entity
@Table(name = "deliveries", schema = "delivery_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Delivery extends AbstractAggregateRoot<Delivery> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false)
    private Long orderId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "courier_id")
    private Courier courier;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private DeliveryStatus status;

    @Column(name = "assigned_at")
    private LocalDateTime assignedAt;

    @Column(name = "picked_up_at")
    private LocalDateTime pickedUpAt;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public static Delivery create(Long orderId) {
        Delivery delivery = new Delivery();
        delivery.orderId = orderId;
        delivery.status = DeliveryStatus.PENDING;
        delivery.createdAt = LocalDateTime.now();
        delivery.updatedAt = LocalDateTime.now();
        return delivery;
    }

    public void assignCourier(Courier courier) {
        if (this.status != DeliveryStatus.PENDING) {
            throw new InvalidStateException("Entrega já foi atribuída");
        }
        this.courier = courier;
        this.status = DeliveryStatus.ASSIGNED;
        this.assignedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        courier.markBusy();
        registerEvent(new DeliveryAssignedEvent(this.id, this.orderId, courier.getId(), courier.getName()));
    }

    public void markPickedUp() {
        if (this.status != DeliveryStatus.ASSIGNED) {
            throw new InvalidStateException("Entrega não está atribuída a um entregador");
        }
        this.status = DeliveryStatus.PICKED_UP;
        this.pickedUpAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void complete() {
        if (this.status != DeliveryStatus.PICKED_UP && this.status != DeliveryStatus.ASSIGNED) {
            throw new InvalidStateException("Entrega não pode ser concluída neste estado");
        }
        this.status = DeliveryStatus.DELIVERED;
        this.deliveredAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        if (this.courier != null) {
            this.courier.markAvailable();
        }
        registerEvent(new DeliveryCompletedEvent(this.id, this.orderId));
    }

    public boolean isActive() {
        return this.status != DeliveryStatus.DELIVERED;
    }
}
