package br.com.logdash.backend.catalog.domain;

import br.com.logdash.backend.catalog.domain.model.Product;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class ProductTest {

    private Product createTestProduct(int stockQuantity) {
        return Product.create(
                "Pizza Margherita",
                "Pizza clássica",
                new BigDecimal("39.90"),
                "http://img.com/pizza.jpg",
                stockQuantity,
                5,
                null
        );
    }

    @Test
    void shouldCreateProductWithCorrectValues() {
        Product product = createTestProduct(20);

        assertEquals("Pizza Margherita", product.getName());
        assertEquals(new BigDecimal("39.90"), product.getPrice());
        assertEquals(20, product.getStockQuantity());
        assertTrue(product.isAvailable());
        assertFalse(product.isDeleted());
        assertNotNull(product.getCreatedAt());
    }

    @Test
    void shouldDecrementStock() {
        Product product = createTestProduct(10);
        product.decrementStock(3);

        assertEquals(7, product.getStockQuantity());
    }

    @Test
    void shouldThrowWhenDecrementExceedsStock() {
        Product product = createTestProduct(5);

        assertThrows(InvalidStateException.class, () -> product.decrementStock(10));
    }

    @Test
    void shouldThrowWhenDecrementZeroOrNegative() {
        Product product = createTestProduct(10);

        assertThrows(IllegalArgumentException.class, () -> product.decrementStock(0));
        assertThrows(IllegalArgumentException.class, () -> product.decrementStock(-1));
    }

    @Test
    void shouldIncrementStock() {
        Product product = createTestProduct(10);
        product.incrementStock(5);

        assertEquals(15, product.getStockQuantity());
    }

    @Test
    void shouldSoftDelete() {
        Product product = createTestProduct(10);
        product.softDelete();

        assertTrue(product.isDeleted());
        assertFalse(product.isAvailable());
    }

    @Test
    void shouldThrowOnDoubleSoftDelete() {
        Product product = createTestProduct(10);
        product.softDelete();

        assertThrows(InvalidStateException.class, product::softDelete);
    }

    @Test
    void shouldToggleAvailability() {
        Product product = createTestProduct(10);
        product.toggleAvailability(false);

        assertFalse(product.isAvailable());

        product.toggleAvailability(true);
        assertTrue(product.isAvailable());
    }

    @Test
    void shouldThrowToggleOnDeletedProduct() {
        Product product = createTestProduct(10);
        product.softDelete();

        assertThrows(InvalidStateException.class, () -> product.toggleAvailability(true));
    }

    @Test
    void shouldDetectLowStock() {
        Product product = createTestProduct(3);
        assertTrue(product.isLowStock()); // 3 <= 5 (minStockAlert)
    }

    @Test
    void shouldNotDetectLowStockWhenSufficient() {
        Product product = createTestProduct(20);
        assertFalse(product.isLowStock()); // 20 > 5
    }
}
