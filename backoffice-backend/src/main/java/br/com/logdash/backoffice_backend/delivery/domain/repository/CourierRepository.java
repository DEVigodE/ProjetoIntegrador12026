package br.com.logdash.backoffice_backend.delivery.domain.repository;

import br.com.logdash.backoffice_backend.delivery.domain.model.Courier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface CourierRepository {
    Courier save(Courier courier);
    Optional<Courier> findById(Long id);
    Page<Courier> findAll(Pageable pageable);
    List<Courier> findAvailable();
}
