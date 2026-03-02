package br.com.logdash.backoffice_backend.catalog.domain.service;

import br.com.logdash.backoffice_backend.catalog.domain.model.Product;
import br.com.logdash.backoffice_backend.catalog.domain.repository.ProductRepository;
import br.com.logdash.backoffice_backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProductDomainService {

    private final ProductRepository productRepository;

    public void decrementStock(Long productId, int quantity) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new ResourceNotFoundException("Produto não encontrado: " + productId));
        product.decrementStock(quantity);
        productRepository.save(product);
    }
}
