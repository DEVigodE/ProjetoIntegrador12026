package br.com.logdash.backend.orders.infrastructure.security;

import br.com.logdash.backend.orders.domain.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

@Component("orderSecurity")
@RequiredArgsConstructor
public class OrderSecurity {

    private final OrderRepository orderRepository;

    public boolean isOwner(Long orderId, Authentication authentication) {
        String subject = authentication.getName();
        if (subject == null) return false;
        return orderRepository.findById(orderId)
                .map(order -> subject.equals(order.getCustomerId()))
                .orElse(false);
    }
}
