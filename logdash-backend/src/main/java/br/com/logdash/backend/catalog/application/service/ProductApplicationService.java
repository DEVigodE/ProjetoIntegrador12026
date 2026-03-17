package br.com.logdash.backend.catalog.application.service;

import br.com.logdash.backend.catalog.application.dto.*;
import br.com.logdash.backend.catalog.domain.model.Category;
import br.com.logdash.backend.catalog.domain.model.Product;
import br.com.logdash.backend.catalog.domain.repository.CategoryRepository;
import br.com.logdash.backend.catalog.domain.repository.ProductRepository;
import br.com.logdash.backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductApplicationService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    @Transactional(readOnly = true)
    public Page<ProductResponse> listProducts(Long categoryId, String name, Pageable pageable) {
        if (categoryId != null) {
            return productRepository.findByCategory(categoryId, pageable).map(ProductResponse::from);
        }
        if (name != null && !name.isBlank()) {
            return productRepository.findByNameContaining(name, pageable).map(ProductResponse::from);
        }
        return productRepository.findAllActive(pageable).map(ProductResponse::from);
    }

    @Transactional(readOnly = true)
    public ProductResponse getProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Produto não encontrado: " + id));
        return ProductResponse.from(product);
    }

    @Transactional
    public ProductResponse createProduct(ProductRequest request) {
        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Categoria não encontrada: " + request.getCategoryId()));
        }
        Product product = Product.create(
                request.getName(),
                request.getDescription(),
                request.getPrice(),
                request.getImageUrl(),
                request.getStockQuantity(),
                request.getMinStockAlert(),
                category
        );
        product = productRepository.save(product);
        return ProductResponse.from(product);
    }

    @Transactional
    public ProductResponse updateProduct(Long id, ProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Produto não encontrado: " + id));
        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Categoria não encontrada: " + request.getCategoryId()));
        }
        product.update(
                request.getName(),
                request.getDescription(),
                request.getPrice(),
                request.getImageUrl(),
                request.getStockQuantity(),
                request.getMinStockAlert(),
                category
        );
        product = productRepository.save(product);
        return ProductResponse.from(product);
    }

    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Produto não encontrado: " + id));
        product.softDelete();
        productRepository.save(product);
    }

    @Transactional
    public void toggleAvailability(Long id, boolean available) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Produto não encontrado: " + id));
        product.toggleAvailability(available);
        productRepository.save(product);
    }

    // Category operations

    @Transactional(readOnly = true)
    public List<CategoryResponse> listCategories() {
        return categoryRepository.findAllActive().stream()
                .map(CategoryResponse::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public CategoryResponse createCategory(CategoryRequest request) {
        Category category = Category.create(request.getName(), request.getDescription());
        category = categoryRepository.save(category);
        return CategoryResponse.from(category);
    }
}
