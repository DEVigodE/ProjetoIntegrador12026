package br.com.logdash.backoffice_backend.orders.domain.repository;

import br.com.logdash.backoffice_backend.orders.domain.model.Order;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface OrderRepository {
    Order save(Order order);
    Optional<Order> findById(Long id);
    Page<Order> findAll(Pageable pageable);
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);
    Page<Order> findActive(Pageable pageable);
}
