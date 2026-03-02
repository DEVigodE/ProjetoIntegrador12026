package br.com.logdash.backoffice_backend.catalog.domain.model;

import br.com.logdash.backoffice_backend.catalog.domain.event.ProductCreatedEvent;
import br.com.logdash.backoffice_backend.catalog.domain.event.StockChangedEvent;
import br.com.logdash.backoffice_backend.shared.application.exception.InvalidStateException;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.AbstractAggregateRoot;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "products", schema = "catalog_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Product extends AbstractAggregateRoot<Product> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(nullable = false)
    private boolean available = true;

    @Column(name = "stock_quantity", nullable = false)
    private int stockQuantity = 0;

    @Column(name = "min_stock_alert", nullable = false)
    private int minStockAlert = 10;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public static Product create(String name, String description, BigDecimal price,
                                  String imageUrl, int stockQuantity, int minStockAlert,
                                  Category category) {
        Product product = new Product();
        product.name = name;
        product.description = description;
        product.price = price;
        product.imageUrl = imageUrl;
        product.stockQuantity = stockQuantity;
        product.minStockAlert = minStockAlert;
        product.category = category;
        product.available = true;
        product.createdAt = LocalDateTime.now();
        product.updatedAt = LocalDateTime.now();
        product.registerEvent(new ProductCreatedEvent(null, name));
        return product;
    }

    public void update(String name, String description, BigDecimal price,
                       String imageUrl, int stockQuantity, int minStockAlert,
                       Category category) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.imageUrl = imageUrl;
        this.stockQuantity = stockQuantity;
        this.minStockAlert = minStockAlert;
        this.category = category;
        this.updatedAt = LocalDateTime.now();
    }

    public void softDelete() {
        if (this.deletedAt != null) {
            throw new InvalidStateException("Produto já foi removido");
        }
        this.deletedAt = LocalDateTime.now();
        this.available = false;
        this.updatedAt = LocalDateTime.now();
    }

    public void toggleAvailability(boolean available) {
        if (this.deletedAt != null) {
            throw new InvalidStateException("Produto removido não pode ser alterado");
        }
        this.available = available;
        this.updatedAt = LocalDateTime.now();
    }

    public void decrementStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantidade deve ser positiva");
        }
        if (this.stockQuantity < quantity) {
            throw new InvalidStateException("Estoque insuficiente para o produto: " + this.name);
        }
        int previousQuantity = this.stockQuantity;
        this.stockQuantity -= quantity;
        this.updatedAt = LocalDateTime.now();
        registerEvent(new StockChangedEvent(this.id, previousQuantity, this.stockQuantity));
    }

    public void incrementStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantidade deve ser positiva");
        }
        int previousQuantity = this.stockQuantity;
        this.stockQuantity += quantity;
        this.updatedAt = LocalDateTime.now();
        registerEvent(new StockChangedEvent(this.id, previousQuantity, this.stockQuantity));
    }

    public boolean isLowStock() {
        return this.stockQuantity <= this.minStockAlert;
    }

    public boolean isDeleted() {
        return this.deletedAt != null;
    }
}
