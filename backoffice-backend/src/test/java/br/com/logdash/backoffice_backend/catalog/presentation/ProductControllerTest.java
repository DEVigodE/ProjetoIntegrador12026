package br.com.logdash.backoffice_backend.catalog.presentation;

import br.com.logdash.backoffice_backend.catalog.application.dto.ProductResponse;
import br.com.logdash.backoffice_backend.catalog.application.service.ProductApplicationService;
import br.com.logdash.backoffice_backend.catalog.presentation.controller.ProductController;
import br.com.logdash.backoffice_backend.shared.infrastructure.config.SecurityConfig;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ProductController.class)
@Import(SecurityConfig.class)
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private ProductApplicationService productService;

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldListProducts() throws Exception {
        ProductResponse response = ProductResponse.builder()
                .id(1L)
                .name("Pizza Margherita")
                .price(new BigDecimal("39.90"))
                .available(true)
                .stockQuantity(20)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        when(productService.listProducts(isNull(), isNull(), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(response)));

        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].name").value("Pizza Margherita"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldCreateProduct() throws Exception {
        ProductResponse response = ProductResponse.builder()
                .id(1L)
                .name("Pizza Margherita")
                .price(new BigDecimal("39.90"))
                .available(true)
                .stockQuantity(20)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        when(productService.createProduct(any())).thenReturn(response);

        String json = """
                {
                    "name": "Pizza Margherita",
                    "price": 39.90,
                    "stockQuantity": 20,
                    "minStockAlert": 5
                }
                """;

        mockMvc.perform(post("/api/products")
                        .contentType("application/json")
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Pizza Margherita"));
    }

    @Test
    void shouldReturn401WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldDeleteProduct() throws Exception {
        mockMvc.perform(delete("/api/products/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    @WithMockUser(roles = "OPERATOR")
    void shouldNotAllowOperatorToDelete() throws Exception {
        mockMvc.perform(delete("/api/products/1"))
                .andExpect(status().isForbidden());
    }
}
