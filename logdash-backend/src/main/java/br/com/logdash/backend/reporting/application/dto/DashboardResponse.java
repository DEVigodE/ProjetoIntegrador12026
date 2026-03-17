package br.com.logdash.backend.reporting.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {

    private long totalOrdersToday;
    private long pendingOrders;
    private long activeDeliveries;
    private long availableCouriers;
    private BigDecimal revenueToday;
    private List<TopProductResponse> topSellingProducts;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopProductResponse {
        private Long productId;
        private String productName;
        private long totalQuantitySold;
        private BigDecimal totalRevenue;
    }
}
