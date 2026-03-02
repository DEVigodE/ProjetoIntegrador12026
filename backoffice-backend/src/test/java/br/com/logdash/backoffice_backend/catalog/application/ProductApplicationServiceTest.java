package br.com.logdash.backoffice_backend.catalog.application;

import br.com.logdash.backoffice_backend.catalog.application.dto.ProductRequest;
import br.com.logdash.backoffice_backend.catalog.application.dto.ProductResponse;
import br.com.logdash.backoffice_backend.catalog.application.service.ProductApplicationService;
import br.com.logdash.backoffice_backend.catalog.domain.model.Product;
import br.com.logdash.backoffice_backend.catalog.domain.repository.CategoryRepository;
import br.com.logdash.backoffice_backend.catalog.domain.repository.ProductRepository;
import br.com.logdash.backoffice_backend.shared.application.exception.ResourceNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductApplicationServiceTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @InjectMocks
    private ProductApplicationService productApplicationService;

    private ProductRequest createTestRequest() {
        return new ProductRequest(
                "Pizza Margherita",
                "Pizza clássica",
                new BigDecimal("39.90"),
                "http://img.com/pizza.jpg",
                20,
                5,
                null
        );
    }

    @Test
    void shouldCreateProduct() {
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ProductResponse response = productApplicationService.createProduct(createTestRequest());

        assertNotNull(response);
        assertEquals("Pizza Margherita", response.getName());
        assertTrue(response.isAvailable());
        verify(productRepository).save(any(Product.class));
    }

    @Test
    void shouldThrowWhenProductNotFound() {
        when(productRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class,
                () -> productApplicationService.getProduct(999L));
    }

    @Test
    void shouldDeleteProduct() {
        Product product = Product.create("Pizza", "Desc", new BigDecimal("39.90"),
                null, 10, 5, null);
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        productApplicationService.deleteProduct(1L);

        assertTrue(product.isDeleted());
        assertFalse(product.isAvailable());
        verify(productRepository).save(product);
    }

    @Test
    void shouldToggleAvailability() {
        Product product = Product.create("Pizza", "Desc", new BigDecimal("39.90"),
                null, 10, 5, null);
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> invocation.getArgument(0));

        productApplicationService.toggleAvailability(1L, false);

        assertFalse(product.isAvailable());
    }
}
