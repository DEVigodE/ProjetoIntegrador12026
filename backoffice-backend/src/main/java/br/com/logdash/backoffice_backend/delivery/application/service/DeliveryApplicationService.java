package br.com.logdash.backoffice_backend.delivery.application.service;

import br.com.logdash.backoffice_backend.delivery.application.dto.*;
import br.com.logdash.backoffice_backend.delivery.domain.model.Courier;
import br.com.logdash.backoffice_backend.delivery.domain.model.Delivery;
import br.com.logdash.backoffice_backend.delivery.domain.repository.CourierRepository;
import br.com.logdash.backoffice_backend.delivery.domain.repository.DeliveryRepository;
import br.com.logdash.backoffice_backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeliveryApplicationService {

    private final CourierRepository courierRepository;
    private final DeliveryRepository deliveryRepository;

    // ---- Courier operations ----

    @Transactional(readOnly = true)
    public Page<CourierResponse> listCouriers(Pageable pageable) {
        return courierRepository.findAll(pageable).map(CourierResponse::from);
    }

    @Transactional
    public CourierResponse createCourier(CourierRequest request) {
        Courier courier = Courier.create(
                request.getName(),
                request.getPhone(),
                request.getEmail(),
                request.getVehicleType(),
                request.getVehiclePlate()
        );
        courier = courierRepository.save(courier);
        return CourierResponse.from(courier);
    }

    @Transactional
    public CourierResponse updateCourier(Long id, CourierRequest request) {
        Courier courier = courierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Entregador não encontrado: " + id));
        courier.update(
                request.getName(),
                request.getPhone(),
                request.getEmail(),
                request.getVehicleType(),
                request.getVehiclePlate()
        );
        courier = courierRepository.save(courier);
        return CourierResponse.from(courier);
    }

    @Transactional
    public CourierResponse activateCourier(Long id) {
        Courier courier = courierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Entregador não encontrado: " + id));
        courier.activate();
        courier = courierRepository.save(courier);
        return CourierResponse.from(courier);
    }

    @Transactional
    public CourierResponse deactivateCourier(Long id) {
        Courier courier = courierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Entregador não encontrado: " + id));
        courier.deactivate();
        courier = courierRepository.save(courier);
        return CourierResponse.from(courier);
    }

    @Transactional(readOnly = true)
    public List<CourierResponse> getAvailableCouriers() {
        return courierRepository.findAvailable().stream()
                .map(CourierResponse::from)
                .collect(Collectors.toList());
    }

    // ---- Delivery operations ----

    @Transactional
    public DeliveryResponse createDelivery(CreateDeliveryRequest request) {
        Delivery delivery = Delivery.create(request.getOrderId());
        delivery = deliveryRepository.save(delivery);
        return DeliveryResponse.from(delivery);
    }

    @Transactional
    public DeliveryResponse assignCourier(Long deliveryId, Long courierId) {
        Delivery delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException("Entrega não encontrada: " + deliveryId));
        Courier courier = courierRepository.findById(courierId)
                .orElseThrow(() -> new ResourceNotFoundException("Entregador não encontrado: " + courierId));
        delivery.assignCourier(courier);
        courierRepository.save(courier);
        delivery = deliveryRepository.save(delivery);
        return DeliveryResponse.from(delivery);
    }

    @Transactional(readOnly = true)
    public Page<DeliveryResponse> getActiveDeliveries(Pageable pageable) {
        return deliveryRepository.findActive(pageable).map(DeliveryResponse::from);
    }
}
