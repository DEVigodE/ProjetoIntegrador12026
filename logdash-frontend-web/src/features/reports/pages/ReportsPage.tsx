import { useState } from 'react';
import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import DateRangePicker from '../components/DateRangePicker';
import MetricsCards from '../components/MetricsCards';
import SalesReportTable from '../components/SalesReportTable';
import TopSellingProducts from '../components/TopSellingProducts';
import { useSalesReport } from '../hooks/useSalesReport';
import { useTopSellingProducts } from '../hooks/useTopSellingProducts';
import { useMetrics } from '../hooks/useMetrics';

function getDefaultDates() {
  const end = new Date();
  const start = new Date();
  start.setDate(start.getDate() - 7);
  return {
    startDate: start.toISOString().split('T')[0],
    endDate: end.toISOString().split('T')[0],
  };
}

export default function ReportsPage() {
  const defaults = getDefaultDates();
  const [startDate, setStartDate] = useState(defaults.startDate);
  const [endDate, setEndDate] = useState(defaults.endDate);

  const { data: metrics, isLoading: loadingMetrics } = useMetrics();
  const { data: salesReport, isLoading: loadingSales, isError: errorSales } = useSalesReport(startDate, endDate);
  const { data: topProducts, isLoading: loadingProducts } = useTopSellingProducts();

  function handleFilter(newStart: string, newEnd: string) {
    setStartDate(newStart);
    setEndDate(newEnd);
  }

  const isLoading = loadingMetrics || loadingSales || loadingProducts;

  if (isLoading) {
    return (
      <>
        <PageHeader title="Relatorios" />
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      </>
    );
  }

  return (
    <>
      <PageHeader title="Relatorios" />

      <div className="space-y-6">
        {/* Metricas globais */}
        {metrics && <MetricsCards data={metrics} />}

        {/* Filtro de data */}
        <DateRangePicker
          defaultStartDate={startDate}
          defaultEndDate={endDate}
          onFilter={handleFilter}
        />

        {/* Vendas do periodo */}
        {errorSales ? (
          <EmptyState
            title="Erro ao carregar relatorio"
            description="Tente novamente mais tarde."
          />
        ) : salesReport ? (
          <SalesReportTable data={salesReport} />
        ) : null}

        {/* Top produtos */}
        {topProducts && <TopSellingProducts products={topProducts} />}
      </div>
    </>
  );
}
