package br.com.logdash.backoffice_backend.catalog.domain.repository;

import br.com.logdash.backoffice_backend.catalog.domain.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;

public interface ProductRepository {
    Product save(Product product);
    Optional<Product> findById(Long id);
    Page<Product> findAllActive(Pageable pageable);
    Page<Product> findByCategory(Long categoryId, Pageable pageable);
    Page<Product> findByNameContaining(String name, Pageable pageable);
}
