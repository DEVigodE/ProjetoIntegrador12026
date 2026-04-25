package br.com.logdash.backend.delivery.application.service;

import br.com.logdash.backend.delivery.application.dto.*;
import br.com.logdash.backend.delivery.application.dto.CourierSelfRegisterRequest;
import br.com.logdash.backend.delivery.domain.model.Courier;
import br.com.logdash.backend.delivery.domain.model.Delivery;
import br.com.logdash.backend.delivery.domain.repository.CourierRepository;
import br.com.logdash.backend.delivery.domain.repository.DeliveryRepository;
import br.com.logdash.backend.shared.application.exception.InvalidStateException;
import br.com.logdash.backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
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
                request.getVehiclePlate(),
                request.getKeycloakId()
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

    // ---- Courier self-service operations ----

    /** Verifica se existe perfil de entregador para o keycloakId informado. */
    @Transactional(readOnly = true)
    public Optional<CourierResponse> getMyCourierProfile(String keycloakId) {
        return courierRepository.findByKeycloakId(keycloakId).map(CourierResponse::from);
    }

    /**
     * Auto-cadastro: cria perfil de entregador vinculado ao keycloakId do JWT.
     * Retorna o perfil existente se já estiver cadastrado.
     */
    @Transactional
    public CourierResponse selfRegister(String keycloakId, CourierSelfRegisterRequest request) {
        return courierRepository.findByKeycloakId(keycloakId)
                .map(CourierResponse::from)
                .orElseGet(() -> {
                    Courier courier = Courier.create(
                            request.getName(),
                            request.getPhone(),
                            null,
                            request.getVehicleType(),
                            request.getVehiclePlate(),
                            keycloakId
                    );
                    courier.markAvailable();
                    courier = courierRepository.save(courier);
                    return CourierResponse.from(courier);
                });
    }

    @Transactional(readOnly = true)
    public Optional<DeliveryResponse> getMyActiveDelivery(String keycloakId) {
        Courier courier = courierRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new ResourceNotFoundException("Perfil de entregador não encontrado para este usuário"));
        return deliveryRepository.findActiveByCourierId(courier.getId())
                .map(DeliveryResponse::from);
    }

    @Transactional
    public DeliveryResponse selfAssign(Long orderId, String keycloakId) {
        Courier courier = courierRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new ResourceNotFoundException("Perfil de entregador não encontrado para este usuário"));
        if (!courier.isAvailable()) {
            throw new InvalidStateException("Entregador não está disponível para aceitar pedidos");
        }
        if (deliveryRepository.existsByOrderIdAndStatusNotDelivered(orderId)) {
            throw new InvalidStateException("Pedido já possui entrega ativa");
        }
        Delivery delivery = Delivery.create(orderId);
        delivery = deliveryRepository.save(delivery);
        delivery.assignCourier(courier);
        courierRepository.save(courier);
        delivery = deliveryRepository.save(delivery);
        return DeliveryResponse.from(delivery);
    }

    @Transactional
    public DeliveryResponse markPickedUp(Long deliveryId, String keycloakId) {
        Courier courier = courierRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new ResourceNotFoundException("Perfil de entregador não encontrado para este usuário"));
        Delivery delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException("Entrega não encontrada: " + deliveryId));
        if (delivery.getCourier() == null || !delivery.getCourier().getId().equals(courier.getId())) {
            throw new InvalidStateException("Entrega não pertence a este entregador");
        }
        delivery.markPickedUp();
        delivery = deliveryRepository.save(delivery);
        return DeliveryResponse.from(delivery);
    }

    @Transactional
    public DeliveryResponse completeDelivery(Long deliveryId, String keycloakId) {
        Courier courier = courierRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new ResourceNotFoundException("Perfil de entregador não encontrado para este usuário"));
        Delivery delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException("Entrega não encontrada: " + deliveryId));
        if (delivery.getCourier() == null || !delivery.getCourier().getId().equals(courier.getId())) {
            throw new InvalidStateException("Entrega não pertence a este entregador");
        }
        delivery.complete();
        courierRepository.save(courier);
        delivery = deliveryRepository.save(delivery);
        return DeliveryResponse.from(delivery);
    }
}
