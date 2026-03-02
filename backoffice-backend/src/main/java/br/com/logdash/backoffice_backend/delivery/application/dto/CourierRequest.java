package br.com.logdash.backoffice_backend.delivery.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CourierRequest {

    @NotBlank(message = "Nome do entregador é obrigatório")
    private String name;

    @NotBlank(message = "Telefone do entregador é obrigatório")
    private String phone;

    private String email;
    private String vehicleType;
    private String vehiclePlate;
}
