package br.com.logdash.backend.delivery.infrastructure.persistence;

import br.com.logdash.backend.delivery.domain.model.Delivery;
import br.com.logdash.backend.delivery.domain.repository.DeliveryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class DeliveryRepositoryImpl implements DeliveryRepository {

    private final DeliveryJpaRepository jpaRepository;

    @Override
    public Delivery save(Delivery delivery) {
        return jpaRepository.save(delivery);
    }

    @Override
    public Optional<Delivery> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Optional<Delivery> findActiveByCourierId(Long courierId) {
        return jpaRepository.findActiveByCourierId(courierId);
    }

    @Override
    public boolean existsByOrderIdAndStatusNotDelivered(Long orderId) {
        return jpaRepository.existsByOrderIdAndStatusNotDelivered(orderId);
    }

    @Override
    public Page<Delivery> findActive(Pageable pageable) {
        return jpaRepository.findActive(pageable);
    }
}
