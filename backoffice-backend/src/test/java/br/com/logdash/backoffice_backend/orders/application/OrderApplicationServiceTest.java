package br.com.logdash.backoffice_backend.orders.application;

import br.com.logdash.backoffice_backend.orders.application.dto.CreateOrderRequest;
import br.com.logdash.backoffice_backend.orders.application.dto.OrderResponse;
import br.com.logdash.backoffice_backend.orders.application.dto.RejectOrderRequest;
import br.com.logdash.backoffice_backend.orders.application.service.OrderApplicationService;
import br.com.logdash.backoffice_backend.orders.domain.model.Order;
import br.com.logdash.backoffice_backend.orders.domain.repository.OrderRepository;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backoffice_backend.shared.application.exception.ResourceNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OrderApplicationServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderApplicationService orderApplicationService;

    private CreateOrderRequest createTestRequest() {
        CreateOrderRequest request = new CreateOrderRequest();
        request.setCustomerName("João Silva");
        request.setCustomerPhone("11999999999");
        request.setCustomerEmail("joao@email.com");
        request.setDeliveryStreet("Rua A");
        request.setDeliveryNumber("100");
        request.setDeliveryCity("São Paulo");
        request.setDeliveryState("SP");
        request.setDeliveryZipCode("01001-000");

        CreateOrderRequest.OrderItemRequest item = new CreateOrderRequest.OrderItemRequest();
        item.setProductId(1L);
        item.setProductName("Pizza");
        item.setUnitPrice(new BigDecimal("39.90"));
        item.setQuantity(2);
        request.setItems(List.of(item));

        return request;
    }

    @Test
    void shouldCreateOrder() {
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        OrderResponse response = orderApplicationService.createOrder(createTestRequest());

        assertNotNull(response);
        assertEquals("João Silva", response.getCustomerName());
        assertEquals(OrderStatus.PENDING, response.getStatus());
        verify(orderRepository, times(2)).save(any(Order.class));
    }

    @Test
    void shouldThrowWhenOrderNotFound() {
        when(orderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> orderApplicationService.getOrder(999L));
    }

    @Test
    void shouldAcceptOrder() {
        Order order = Order.create("João", "11999", null, null, null, null, null, null, null, null, null);
        order.addItem(1L, "Pizza", new BigDecimal("39.90"), 1, null);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        orderApplicationService.acceptOrder(1L);

        assertEquals(OrderStatus.ACCEPTED, order.getStatus());
        verify(orderRepository).save(order);
    }

    @Test
    void shouldRejectOrder() {
        Order order = Order.create("João", "11999", null, null, null, null, null, null, null, null, null);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any(Order.class))).thenAnswer(invocation -> invocation.getArgument(0));

        orderApplicationService.rejectOrder(1L, new RejectOrderRequest("Sem ingredientes"));

        assertEquals(OrderStatus.CANCELLED, order.getStatus());
        assertEquals("Sem ingredientes", order.getRejectedReason());
    }
}
