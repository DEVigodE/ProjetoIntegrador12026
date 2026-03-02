package br.com.logdash.backoffice_backend.orders.domain;

import br.com.logdash.backoffice_backend.orders.domain.model.Order;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backoffice_backend.shared.application.exception.InvalidStateException;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class OrderTest {

    private Order createTestOrder() {
        Order order = Order.create(
                "João Silva", "11999999999", "joao@email.com",
                "Rua A", "100", "Apto 1", "Centro",
                "São Paulo", "SP", "01001-000", null
        );
        order.addItem(1L, "Pizza Margherita", new BigDecimal("39.90"), 2, null);
        order.addItem(2L, "Coca-Cola", new BigDecimal("8.00"), 1, null);
        return order;
    }

    @Test
    void shouldCreateOrderWithPendingStatus() {
        Order order = createTestOrder();

        assertEquals(OrderStatus.PENDING, order.getStatus());
        assertNotNull(order.getCreatedAt());
        assertTrue(order.isActive());
    }

    @Test
    void shouldCalculateTotalCorrectly() {
        Order order = createTestOrder();
        // 39.90 * 2 + 8.00 * 1 = 87.80
        assertEquals(new BigDecimal("87.80"), order.getTotalAmount());
    }

    @Test
    void shouldAcceptPendingOrder() {
        Order order = createTestOrder();
        order.accept();

        assertEquals(OrderStatus.ACCEPTED, order.getStatus());
    }

    @Test
    void shouldThrowWhenAcceptingNonPendingOrder() {
        Order order = createTestOrder();
        order.accept(); // now ACCEPTED

        assertThrows(InvalidStateException.class, order::accept);
    }

    @Test
    void shouldRejectPendingOrder() {
        Order order = createTestOrder();
        order.reject("Sem ingredientes");

        assertEquals(OrderStatus.CANCELLED, order.getStatus());
        assertEquals("Sem ingredientes", order.getRejectedReason());
        assertFalse(order.isActive());
    }

    @Test
    void shouldThrowWhenRejectingNonPendingOrder() {
        Order order = createTestOrder();
        order.accept();

        assertThrows(InvalidStateException.class, () -> order.reject("Motivo"));
    }

    @Test
    void shouldUpdateStatusInValidFlow() {
        Order order = createTestOrder();
        order.accept();
        order.updateStatus(OrderStatus.PREPARING);

        assertEquals(OrderStatus.PREPARING, order.getStatus());
    }

    @Test
    void shouldThrowOnInvalidStatusTransition() {
        Order order = createTestOrder();
        // PENDING -> DELIVERED is not valid
        assertThrows(InvalidStateException.class,
                () -> order.updateStatus(OrderStatus.DELIVERED));
    }

    @Test
    void shouldFollowFullStatusFlow() {
        Order order = createTestOrder();
        order.accept();
        assertEquals(OrderStatus.ACCEPTED, order.getStatus());

        order.updateStatus(OrderStatus.PREPARING);
        assertEquals(OrderStatus.PREPARING, order.getStatus());

        order.updateStatus(OrderStatus.READY);
        assertEquals(OrderStatus.READY, order.getStatus());

        order.updateStatus(OrderStatus.OUT_FOR_DELIVERY);
        assertEquals(OrderStatus.OUT_FOR_DELIVERY, order.getStatus());

        order.markAsDelivered();
        assertEquals(OrderStatus.DELIVERED, order.getStatus());
        assertFalse(order.isActive());
    }

    @Test
    void shouldThrowMarkAsDeliveredFromWrongStatus() {
        Order order = createTestOrder();
        assertThrows(InvalidStateException.class, order::markAsDelivered);
    }

    @Test
    void shouldNotAllowTransitionFromDelivered() {
        Order order = createTestOrder();
        order.accept();
        order.updateStatus(OrderStatus.PREPARING);
        order.updateStatus(OrderStatus.READY);
        order.updateStatus(OrderStatus.OUT_FOR_DELIVERY);
        order.markAsDelivered();

        assertThrows(InvalidStateException.class,
                () -> order.updateStatus(OrderStatus.CANCELLED));
    }
}
