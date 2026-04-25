package br.com.logdash.backend.delivery.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO para auto-cadastro do entregador via POST /api/couriers/me.
 * O keycloakId é extraído automaticamente do JWT — não precisa ser informado.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CourierSelfRegisterRequest {

    @NotBlank(message = "Nome é obrigatório")
    private String name;

    @NotBlank(message = "Telefone é obrigatório")
    private String phone;

    private String vehicleType;
    private String vehiclePlate;
}
