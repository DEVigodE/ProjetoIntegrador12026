package br.com.logdash.backoffice_backend.delivery.infrastructure.persistence;

import br.com.logdash.backoffice_backend.delivery.domain.model.Courier;
import br.com.logdash.backoffice_backend.delivery.domain.repository.CourierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class CourierRepositoryImpl implements CourierRepository {

    private final CourierJpaRepository jpaRepository;

    @Override
    public Courier save(Courier courier) {
        return jpaRepository.save(courier);
    }

    @Override
    public Optional<Courier> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Page<Courier> findAll(Pageable pageable) {
        return jpaRepository.findAll(pageable);
    }

    @Override
    public List<Courier> findAvailable() {
        return jpaRepository.findAvailable();
    }
}
