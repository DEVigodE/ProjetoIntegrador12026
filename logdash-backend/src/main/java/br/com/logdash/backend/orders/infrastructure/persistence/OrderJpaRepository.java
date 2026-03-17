package br.com.logdash.backend.orders.infrastructure.persistence;

import br.com.logdash.backend.orders.domain.model.Order;
import br.com.logdash.backend.orders.domain.valueobject.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface OrderJpaRepository extends JpaRepository<Order, Long> {

    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    @Query("SELECT o FROM Order o WHERE o.status NOT IN ('DELIVERED', 'CANCELLED')")
    Page<Order> findActive(Pageable pageable);
}
