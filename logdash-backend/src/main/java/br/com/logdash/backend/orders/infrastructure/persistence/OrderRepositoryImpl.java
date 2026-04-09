package br.com.logdash.backend.orders.infrastructure.persistence;

import br.com.logdash.backend.orders.domain.model.Order;
import br.com.logdash.backend.orders.domain.repository.OrderRepository;
import br.com.logdash.backend.orders.domain.valueobject.OrderStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class OrderRepositoryImpl implements OrderRepository {

    private final OrderJpaRepository jpaRepository;

    @Override
    public Order save(Order order) {
        return jpaRepository.save(order);
    }

    @Override
    public Optional<Order> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Page<Order> findAll(Pageable pageable) {
        return jpaRepository.findAll(pageable);
    }

    @Override
    public Page<Order> findByStatus(OrderStatus status, Pageable pageable) {
        return jpaRepository.findByStatus(status, pageable);
    }

    @Override
    public Page<Order> findActive(Pageable pageable) {
        return jpaRepository.findActive(pageable);
    }

    @Override
    public Page<Order> findByCustomerId(String customerId, Pageable pageable) {
        return jpaRepository.findByCustomerId(customerId, pageable);
    }

    @Override
    public Page<Order> findByCustomerIdAndStatus(String customerId, OrderStatus status, Pageable pageable) {
        return jpaRepository.findByCustomerIdAndStatus(customerId, status, pageable);
    }
}
