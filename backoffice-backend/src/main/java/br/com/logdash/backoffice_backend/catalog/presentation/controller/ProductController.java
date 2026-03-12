package br.com.logdash.backoffice_backend.catalog.presentation.controller;

import br.com.logdash.backoffice_backend.catalog.application.dto.*;
import br.com.logdash.backoffice_backend.catalog.application.service.ProductApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springdoc.core.annotations.ParameterObject;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ProductController {

    private final ProductApplicationService productService;

    // ---- Products ----

    @GetMapping("/products")
    public Page<ProductResponse> listProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String name,
            @ParameterObject Pageable pageable) {
        return productService.listProducts(categoryId, name, pageable);
    }

    @GetMapping("/products/{id}")
    public ProductResponse getProduct(@PathVariable Long id) {
        return productService.getProduct(id);
    }

    @PostMapping("/products")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<ProductResponse> createProduct(@Valid @RequestBody ProductRequest request) {
        return ResponseEntity.status(201).body(productService.createProduct(request));
    }

    @PutMapping("/products/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ProductResponse updateProduct(@PathVariable Long id, @Valid @RequestBody ProductRequest request) {
        return productService.updateProduct(id, request);
    }

    @DeleteMapping("/products/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/products/{id}/availability")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<Void> toggleAvailability(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> body) {
        productService.toggleAvailability(id, body.getOrDefault("available", true));
        return ResponseEntity.ok().build();
    }

    // ---- Categories ----

    @GetMapping("/categories")
    public List<CategoryResponse> listCategories() {
        return productService.listCategories();
    }

    @PostMapping("/categories")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CategoryResponse> createCategory(@Valid @RequestBody CategoryRequest request) {
        return ResponseEntity.status(201).body(productService.createCategory(request));
    }
}
