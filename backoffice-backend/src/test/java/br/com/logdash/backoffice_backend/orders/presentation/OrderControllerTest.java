package br.com.logdash.backoffice_backend.orders.presentation;

import br.com.logdash.backoffice_backend.orders.application.dto.OrderResponse;
import br.com.logdash.backoffice_backend.orders.application.service.OrderApplicationService;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backoffice_backend.orders.presentation.controller.OrderController;
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
import java.util.Collections;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(OrderController.class)
@Import(SecurityConfig.class)
class OrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private OrderApplicationService orderService;

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldListOrders() throws Exception {
        OrderResponse response = OrderResponse.builder()
                .id(1L)
                .status(OrderStatus.PENDING)
                .customerName("João Silva")
                .totalAmount(new BigDecimal("87.80"))
                .items(Collections.emptyList())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        when(orderService.listOrders(isNull(), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(response)));

        mockMvc.perform(get("/api/orders"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].customerName").value("João Silva"));
    }

    @Test
    void shouldReturn401WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/orders"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldCreateOrder() throws Exception {
        OrderResponse response = OrderResponse.builder()
                .id(1L)
                .status(OrderStatus.PENDING)
                .customerName("João Silva")
                .totalAmount(new BigDecimal("39.90"))
                .items(Collections.emptyList())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        when(orderService.createOrder(any())).thenReturn(response);

        String json = """
                {
                    "customerName": "João Silva",
                    "customerPhone": "11999999999",
                    "items": [{
                        "productId": 1,
                        "productName": "Pizza",
                        "unitPrice": 39.90,
                        "quantity": 1
                    }]
                }
                """;

        mockMvc.perform(post("/api/orders")
                        .contentType("application/json")
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.customerName").value("João Silva"));
    }

    @Test
    @WithMockUser(roles = "OPERATOR")
    void shouldAcceptOrder() throws Exception {
        mockMvc.perform(patch("/api/orders/1/accept"))
                .andExpect(status().isOk());
    }
}
