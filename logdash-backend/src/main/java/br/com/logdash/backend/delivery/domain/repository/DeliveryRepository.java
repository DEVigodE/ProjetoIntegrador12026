package br.com.logdash.backend.delivery.domain.repository;

import br.com.logdash.backend.delivery.domain.model.Delivery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface DeliveryRepository {
    Delivery save(Delivery delivery);
    Optional<Delivery> findById(Long id);
    Optional<Delivery> findActiveByCourierId(Long courierId);
    boolean existsByOrderIdAndStatusNotDelivered(Long orderId);
    Page<Delivery> findActive(Pageable pageable);
}
