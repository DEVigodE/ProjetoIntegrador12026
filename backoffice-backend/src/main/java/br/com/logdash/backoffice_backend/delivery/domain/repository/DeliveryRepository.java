package br.com.logdash.backoffice_backend.delivery.domain.repository;

import br.com.logdash.backoffice_backend.delivery.domain.model.Delivery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface DeliveryRepository {
    Delivery save(Delivery delivery);
    Optional<Delivery> findById(Long id);
    Page<Delivery> findActive(Pageable pageable);
}
