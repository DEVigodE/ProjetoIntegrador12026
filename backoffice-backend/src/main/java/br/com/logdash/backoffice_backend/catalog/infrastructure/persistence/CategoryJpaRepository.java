package br.com.logdash.backoffice_backend.catalog.infrastructure.persistence;

import br.com.logdash.backoffice_backend.catalog.domain.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CategoryJpaRepository extends JpaRepository<Category, Long> {

    @Query("SELECT c FROM Category c WHERE c.active = true")
    List<Category> findAllActive();
}
