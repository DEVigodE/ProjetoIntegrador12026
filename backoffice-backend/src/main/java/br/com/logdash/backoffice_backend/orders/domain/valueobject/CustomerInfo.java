package br.com.logdash.backoffice_backend.orders.domain.valueobject;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class CustomerInfo {

    private String customerName;
    private String customerPhone;
    private String customerEmail;
}
