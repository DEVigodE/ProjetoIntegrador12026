package br.com.logdash.backend.reporting.application.service;

import br.com.logdash.backend.reporting.application.dto.DashboardResponse;
import br.com.logdash.backend.reporting.application.dto.SalesReportResponse;
import br.com.logdash.backend.reporting.infrastructure.persistence.ReportingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportingApplicationService {

    private final ReportingRepository reportingRepository;

    @Transactional(readOnly = true)
    public SalesReportResponse getSalesReport(LocalDate startDate, LocalDate endDate) {
        long totalOrders = reportingRepository.countOrdersByDateRange(startDate, endDate);
        BigDecimal totalRevenue = reportingRepository.sumRevenueByDateRange(startDate, endDate);
        long deliveredOrders = reportingRepository.countDeliveredOrdersByDateRange(startDate, endDate);
        long cancelledOrders = reportingRepository.countCancelledOrdersByDateRange(startDate, endDate);
        BigDecimal averageOrderValue = totalOrders > 0
                ? totalRevenue.divide(BigDecimal.valueOf(totalOrders), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return SalesReportResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .totalOrders(totalOrders)
                .totalRevenue(totalRevenue)
                .averageOrderValue(averageOrderValue)
                .deliveredOrders(deliveredOrders)
                .cancelledOrders(cancelledOrders)
                .build();
    }

    @Transactional(readOnly = true)
    public List<DashboardResponse.TopProductResponse> getTopSellingProducts(int limit) {
        return reportingRepository.findTopSellingProducts(limit).stream()
                .map(row -> DashboardResponse.TopProductResponse.builder()
                        .productId(((Number) row[0]).longValue())
                        .productName((String) row[1])
                        .totalQuantitySold(((Number) row[2]).longValue())
                        .totalRevenue((BigDecimal) row[3])
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public DashboardResponse getDashboard() {
        return DashboardResponse.builder()
                .totalOrdersToday(reportingRepository.countOrdersToday())
                .pendingOrders(reportingRepository.countPendingOrders())
                .activeDeliveries(reportingRepository.countActiveDeliveries())
                .availableCouriers(reportingRepository.countAvailableCouriers())
                .revenueToday(reportingRepository.sumRevenueToday())
                .topSellingProducts(getTopSellingProducts(5))
                .build();
    }

    @Transactional(readOnly = true)
    public SalesReportResponse getMetrics() {
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysAgo = today.minusDays(30);
        return getSalesReport(thirtyDaysAgo, today);
    }
}
