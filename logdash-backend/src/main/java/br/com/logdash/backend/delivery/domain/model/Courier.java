package br.com.logdash.backend.delivery.domain.model;

import br.com.logdash.backend.delivery.domain.event.CourierRegisteredEvent;
import br.com.logdash.backend.delivery.domain.valueobject.CourierStatus;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.AbstractAggregateRoot;

import java.time.LocalDateTime;

@Entity
@Table(name = "couriers", schema = "delivery_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Courier extends AbstractAggregateRoot<Courier> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "keycloak_id", unique = true)
    private String keycloakId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 20)
    private String phone;

    @Column(unique = true)
    private String email;

    @Column(name = "vehicle_type", length = 50)
    private String vehicleType;

    @Column(name = "vehicle_plate", length = 20)
    private String vehiclePlate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private CourierStatus status;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public static Courier create(String name, String phone, String email,
                                  String vehicleType, String vehiclePlate,
                                  String keycloakId) {
        Courier courier = new Courier();
        courier.keycloakId = keycloakId;
        courier.name = name;
        courier.phone = phone;
        courier.email = email;
        courier.vehicleType = vehicleType;
        courier.vehiclePlate = vehiclePlate;
        courier.status = CourierStatus.OFFLINE;
        courier.active = true;
        courier.createdAt = LocalDateTime.now();
        courier.updatedAt = LocalDateTime.now();
        courier.registerEvent(new CourierRegisteredEvent(null, name));
        return courier;
    }

    public void update(String name, String phone, String email,
                       String vehicleType, String vehiclePlate) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.vehicleType = vehicleType;
        this.vehiclePlate = vehiclePlate;
        this.updatedAt = LocalDateTime.now();
    }

    public void markBusy() {
        if (this.status != CourierStatus.AVAILABLE) {
            throw new InvalidStateException("Entregador não está disponível");
        }
        this.status = CourierStatus.BUSY;
        this.updatedAt = LocalDateTime.now();
    }

    public void markAvailable() {
        this.status = CourierStatus.AVAILABLE;
        this.updatedAt = LocalDateTime.now();
    }

    public void markOffline() {
        this.status = CourierStatus.OFFLINE;
        this.updatedAt = LocalDateTime.now();
    }

    public void activate() {
        if (!this.active) {
            this.active = true;
            this.updatedAt = LocalDateTime.now();
        }
    }

    public void deactivate() {
        if (this.active) {
            this.active = false;
            this.updatedAt = LocalDateTime.now();
        }
    }

    public boolean isAvailable() {
        return this.status == CourierStatus.AVAILABLE && this.active;
    }
}
