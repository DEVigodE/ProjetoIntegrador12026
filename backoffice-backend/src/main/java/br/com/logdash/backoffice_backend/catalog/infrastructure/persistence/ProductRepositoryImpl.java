package br.com.logdash.backoffice_backend.catalog.infrastructure.persistence;

import br.com.logdash.backoffice_backend.catalog.domain.model.Product;
import br.com.logdash.backoffice_backend.catalog.domain.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProductRepositoryImpl implements ProductRepository {

    private final ProductJpaRepository jpaRepository;

    @Override
    public Product save(Product product) {
        return jpaRepository.save(product);
    }

    @Override
    public Optional<Product> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public Page<Product> findAllActive(Pageable pageable) {
        return jpaRepository.findAllActive(pageable);
    }

    @Override
    public Page<Product> findByCategory(Long categoryId, Pageable pageable) {
        return jpaRepository.findByCategoryId(categoryId, pageable);
    }

    @Override
    public Page<Product> findByNameContaining(String name, Pageable pageable) {
        return jpaRepository.findByNameContainingIgnoreCase(name, pageable);
    }
}
