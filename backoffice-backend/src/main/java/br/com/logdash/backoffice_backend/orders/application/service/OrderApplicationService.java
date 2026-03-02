package br.com.logdash.backoffice_backend.orders.application.service;

import br.com.logdash.backoffice_backend.orders.application.dto.*;
import br.com.logdash.backoffice_backend.orders.domain.model.Order;
import br.com.logdash.backoffice_backend.orders.domain.repository.OrderRepository;
import br.com.logdash.backoffice_backend.orders.domain.valueobject.OrderStatus;
import br.com.logdash.backoffice_backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OrderApplicationService {

    private final OrderRepository orderRepository;

    @Transactional(readOnly = true)
    public Page<OrderResponse> listOrders(OrderStatus status, Pageable pageable) {
        if (status != null) {
            return orderRepository.findByStatus(status, pageable).map(OrderResponse::from);
        }
        return orderRepository.findAll(pageable).map(OrderResponse::from);
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrder(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido não encontrado: " + id));
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        Order order = Order.create(
                request.getCustomerName(),
                request.getCustomerPhone(),
                request.getCustomerEmail(),
                request.getDeliveryStreet(),
                request.getDeliveryNumber(),
                request.getDeliveryComplement(),
                request.getDeliveryNeighborhood(),
                request.getDeliveryCity(),
                request.getDeliveryState(),
                request.getDeliveryZipCode(),
                request.getNotes()
        );

        for (CreateOrderRequest.OrderItemRequest itemReq : request.getItems()) {
            order.addItem(
                    itemReq.getProductId(),
                    itemReq.getProductName(),
                    itemReq.getUnitPrice(),
                    itemReq.getQuantity(),
                    itemReq.getNotes()
            );
        }

        order = orderRepository.save(order);
        order.markAsCreated();
        order = orderRepository.save(order);
        return OrderResponse.from(order);
    }

    @Transactional(readOnly = true)
    public Page<OrderResponse> getActiveOrders(Pageable pageable) {
        return orderRepository.findActive(pageable).map(OrderResponse::from);
    }

    @Transactional
    public void acceptOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido não encontrado: " + orderId));
        order.accept();
        orderRepository.save(order);
    }

    @Transactional
    public void rejectOrder(Long orderId, RejectOrderRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido não encontrado: " + orderId));
        order.reject(request.getReason());
        orderRepository.save(order);
    }

    @Transactional
    public void updateStatus(Long orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Pedido não encontrado: " + orderId));
        order.updateStatus(newStatus);
        orderRepository.save(order);
    }
}
