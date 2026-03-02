package br.com.logdash.backoffice_backend.delivery.infrastructure.persistence;

import br.com.logdash.backoffice_backend.delivery.domain.model.Delivery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface DeliveryJpaRepository extends JpaRepository<Delivery, Long> {

    @Query("SELECT d FROM Delivery d WHERE d.status != 'DELIVERED'")
    Page<Delivery> findActive(Pageable pageable);
}
