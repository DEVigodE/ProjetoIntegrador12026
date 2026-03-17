package br.com.logdash.backend.delivery.domain;

import br.com.logdash.backend.delivery.domain.model.Courier;
import br.com.logdash.backend.delivery.domain.valueobject.CourierStatus;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class CourierTest {

    private Courier createTestCourier() {
        return Courier.create("Carlos", "11999998888", "carlos@email.com", "MOTO", "ABC-1234");
    }

    @Test
    void shouldCreateCourierWithAvailableStatus() {
        Courier courier = createTestCourier();

        assertEquals("Carlos", courier.getName());
        assertEquals(CourierStatus.AVAILABLE, courier.getStatus());
        assertTrue(courier.isActive());
        assertTrue(courier.isAvailable());
    }

    @Test
    void shouldMarkCourierAsBusy() {
        Courier courier = createTestCourier();
        courier.markBusy();

        assertEquals(CourierStatus.BUSY, courier.getStatus());
        assertFalse(courier.isAvailable());
    }

    @Test
    void shouldThrowWhenMarkingBusyCourierAsBusy() {
        Courier courier = createTestCourier();
        courier.markBusy();

        assertThrows(InvalidStateException.class, courier::markBusy);
    }

    @Test
    void shouldMarkCourierAsAvailableAfterBusy() {
        Courier courier = createTestCourier();
        courier.markBusy();
        courier.markAvailable();

        assertEquals(CourierStatus.AVAILABLE, courier.getStatus());
        assertTrue(courier.isAvailable());
    }

    @Test
    void shouldMarkCourierAsOffline() {
        Courier courier = createTestCourier();
        courier.markOffline();

        assertEquals(CourierStatus.OFFLINE, courier.getStatus());
        assertFalse(courier.isAvailable());
    }

    @Test
    void shouldDeactivateCourier() {
        Courier courier = createTestCourier();
        courier.deactivate();

        assertFalse(courier.isActive());
        assertFalse(courier.isAvailable());
    }

    @Test
    void shouldUpdateCourierInfo() {
        Courier courier = createTestCourier();
        courier.update("Carlos Silva", "11999997777", "carlos.silva@email.com", "CARRO", "XYZ-9999");

        assertEquals("Carlos Silva", courier.getName());
        assertEquals("11999997777", courier.getPhone());
        assertEquals("CARRO", courier.getVehicleType());
    }
}
