package br.com.logdash.backend.orders.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RejectOrderRequest {

    @NotBlank(message = "Motivo da recusa é obrigatório")
    private String reason;
}
