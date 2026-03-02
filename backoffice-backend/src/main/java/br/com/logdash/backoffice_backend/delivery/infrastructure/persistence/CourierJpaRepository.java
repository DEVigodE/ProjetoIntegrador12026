package br.com.logdash.backoffice_backend.delivery.infrastructure.persistence;

import br.com.logdash.backoffice_backend.delivery.domain.model.Courier;
import br.com.logdash.backoffice_backend.delivery.domain.valueobject.CourierStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CourierJpaRepository extends JpaRepository<Courier, Long> {

    @Query("SELECT c FROM Courier c WHERE c.status = 'AVAILABLE' AND c.active = true")
    List<Courier> findAvailable();
}
