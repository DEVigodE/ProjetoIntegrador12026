package br.com.logdash.backend.reporting.presentation.controller;

import br.com.logdash.backend.reporting.application.dto.DashboardResponse;
import br.com.logdash.backend.reporting.application.dto.SalesReportResponse;
import br.com.logdash.backend.reporting.application.service.ReportingApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportingController {

    private final ReportingApplicationService reportingService;

    @GetMapping("/sales")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public SalesReportResponse getSalesReport(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return reportingService.getSalesReport(startDate, endDate);
    }

    @GetMapping("/products/top-selling")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public List<DashboardResponse.TopProductResponse> getTopSellingProducts(
            @RequestParam(defaultValue = "10") int limit) {
        return reportingService.getTopSellingProducts(limit);
    }

    @GetMapping("/metrics")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public SalesReportResponse getMetrics() {
        return reportingService.getMetrics();
    }

    @GetMapping("/dashboard")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public DashboardResponse getDashboard() {
        return reportingService.getDashboard();
    }
}
