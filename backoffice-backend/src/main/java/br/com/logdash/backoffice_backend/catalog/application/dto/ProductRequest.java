package br.com.logdash.backoffice_backend.catalog.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ProductRequest {

    @NotBlank(message = "Nome do produto é obrigatório")
    private String name;

    private String description;

    @NotNull(message = "Preço é obrigatório")
    @DecimalMin(value = "0.0", message = "Preço não pode ser negativo")
    private BigDecimal price;

    private String imageUrl;

    @Min(value = 0, message = "Quantidade em estoque não pode ser negativa")
    private int stockQuantity;

    @Min(value = 0, message = "Alerta mínimo de estoque não pode ser negativo")
    private int minStockAlert = 10;

    private Long categoryId;
}
