package br.com.logdash.backend.reporting.infrastructure.persistence;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
@RequiredArgsConstructor
public class ReportingRepository {

    private final EntityManager entityManager;

    public long countOrdersByDateRange(LocalDate startDate, LocalDate endDate) {
        String sql = "SELECT COUNT(*) FROM orders_schema.orders WHERE created_at >= :start AND created_at < :end";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startDate.atStartOfDay());
        query.setParameter("end", endDate.plusDays(1).atStartOfDay());
        return ((Number) query.getSingleResult()).longValue();
    }

    public BigDecimal sumRevenueByDateRange(LocalDate startDate, LocalDate endDate) {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders_schema.orders WHERE status = 'DELIVERED' AND created_at >= :start AND created_at < :end";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startDate.atStartOfDay());
        query.setParameter("end", endDate.plusDays(1).atStartOfDay());
        return (BigDecimal) query.getSingleResult();
    }

    public long countDeliveredOrdersByDateRange(LocalDate startDate, LocalDate endDate) {
        String sql = "SELECT COUNT(*) FROM orders_schema.orders WHERE status = 'DELIVERED' AND created_at >= :start AND created_at < :end";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startDate.atStartOfDay());
        query.setParameter("end", endDate.plusDays(1).atStartOfDay());
        return ((Number) query.getSingleResult()).longValue();
    }

    public long countCancelledOrdersByDateRange(LocalDate startDate, LocalDate endDate) {
        String sql = "SELECT COUNT(*) FROM orders_schema.orders WHERE status = 'CANCELLED' AND created_at >= :start AND created_at < :end";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startDate.atStartOfDay());
        query.setParameter("end", endDate.plusDays(1).atStartOfDay());
        return ((Number) query.getSingleResult()).longValue();
    }

    public long countOrdersToday() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        String sql = "SELECT COUNT(*) FROM orders_schema.orders WHERE created_at >= :start";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startOfDay);
        return ((Number) query.getSingleResult()).longValue();
    }

    public long countPendingOrders() {
        String sql = "SELECT COUNT(*) FROM orders_schema.orders WHERE status = 'PENDING'";
        return ((Number) entityManager.createNativeQuery(sql).getSingleResult()).longValue();
    }

    public long countActiveDeliveries() {
        String sql = "SELECT COUNT(*) FROM delivery_schema.deliveries WHERE status != 'DELIVERED'";
        return ((Number) entityManager.createNativeQuery(sql).getSingleResult()).longValue();
    }

    public long countAvailableCouriers() {
        String sql = "SELECT COUNT(*) FROM delivery_schema.couriers WHERE status = 'AVAILABLE' AND active = true";
        return ((Number) entityManager.createNativeQuery(sql).getSingleResult()).longValue();
    }

    public BigDecimal sumRevenueToday() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders_schema.orders WHERE status = 'DELIVERED' AND created_at >= :start";
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("start", startOfDay);
        return (BigDecimal) query.getSingleResult();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findTopSellingProducts(int limit) {
        String sql = """
                SELECT oi.product_id, oi.product_name, SUM(oi.quantity) as total_qty, SUM(oi.subtotal) as total_rev
                FROM orders_schema.order_items oi
                JOIN orders_schema.orders o ON o.id = oi.order_id
                WHERE o.status = 'DELIVERED'
                GROUP BY oi.product_id, oi.product_name
                ORDER BY total_qty DESC
                LIMIT :limit
                """;
        Query query = entityManager.createNativeQuery(sql);
        query.setParameter("limit", limit);
        return query.getResultList();
    }
}
