package br.com.logdash.backend.catalog.domain.model;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Stock {

    private int quantity;
    private int minAlert;

    public boolean isLow() {
        return quantity <= minAlert;
    }

    public Stock decrement(int amount) {
        if (amount > quantity) {
            throw new IllegalStateException("Estoque insuficiente");
        }
        return new Stock(quantity - amount, minAlert);
    }

    public Stock increment(int amount) {
        return new Stock(quantity + amount, minAlert);
    }
}
