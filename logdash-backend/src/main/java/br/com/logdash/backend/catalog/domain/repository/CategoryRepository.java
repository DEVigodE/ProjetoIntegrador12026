package br.com.logdash.backend.catalog.domain.repository;

import br.com.logdash.backend.catalog.domain.model.Category;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository {
    Category save(Category category);
    Optional<Category> findById(Long id);
    List<Category> findAll();
    List<Category> findAllActive();
}
