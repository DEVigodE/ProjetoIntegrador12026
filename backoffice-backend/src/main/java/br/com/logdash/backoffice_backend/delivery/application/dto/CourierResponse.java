package br.com.logdash.backoffice_backend.delivery.application.dto;

import br.com.logdash.backoffice_backend.delivery.domain.model.Courier;
import br.com.logdash.backoffice_backend.delivery.domain.valueobject.CourierStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CourierResponse {

    private Long id;
    private String name;
    private String phone;
    private String email;
    private String vehicleType;
    private String vehiclePlate;
    private CourierStatus status;
    private boolean active;
    private LocalDateTime createdAt;

    public static CourierResponse from(Courier courier) {
        return CourierResponse.builder()
                .id(courier.getId())
                .name(courier.getName())
                .phone(courier.getPhone())
                .email(courier.getEmail())
                .vehicleType(courier.getVehicleType())
                .vehiclePlate(courier.getVehiclePlate())
                .status(courier.getStatus())
                .active(courier.isActive())
                .createdAt(courier.getCreatedAt())
                .build();
    }
}
