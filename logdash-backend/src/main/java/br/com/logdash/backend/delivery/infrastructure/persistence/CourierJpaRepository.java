package br.com.logdash.backend.delivery.infrastructure.persistence;

import br.com.logdash.backend.delivery.domain.model.Courier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface CourierJpaRepository extends JpaRepository<Courier, Long> {

    @Query("SELECT c FROM Courier c WHERE c.status = 'AVAILABLE' AND c.active = true")
    List<Courier> findAvailable();

    Optional<Courier> findByKeycloakId(String keycloakId);
}
