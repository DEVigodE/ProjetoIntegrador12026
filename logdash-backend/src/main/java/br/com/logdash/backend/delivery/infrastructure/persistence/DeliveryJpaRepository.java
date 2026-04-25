package br.com.logdash.backend.delivery.infrastructure.persistence;

import br.com.logdash.backend.delivery.domain.model.Delivery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface DeliveryJpaRepository extends JpaRepository<Delivery, Long> {

    @Query("SELECT d FROM Delivery d WHERE d.status != 'DELIVERED'")
    Page<Delivery> findActive(Pageable pageable);

    @Query("SELECT d FROM Delivery d WHERE d.courier.id = :courierId AND d.status != 'DELIVERED'")
    Optional<Delivery> findActiveByCourierId(Long courierId);

    @Query("SELECT COUNT(d) > 0 FROM Delivery d WHERE d.orderId = :orderId AND d.status != 'DELIVERED'")
    boolean existsByOrderIdAndStatusNotDelivered(Long orderId);
}
