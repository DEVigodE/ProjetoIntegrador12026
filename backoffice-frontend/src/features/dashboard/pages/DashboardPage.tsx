import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import KpiCard from '../components/KpiCard';
import TopProductsChart from '../components/TopProductsChart';
import ActiveOrdersList from '../components/ActiveOrdersList';
import { useDashboard } from '../hooks/useDashboard';
import { useActiveOrders } from '../../../features/orders/hooks/useActiveOrders';

function formatCurrency(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function DashboardPage() {
  const { data: dashboard, isLoading: loadingDashboard, isError: errorDashboard } = useDashboard();
  const { data: activeOrders = [], isLoading: loadingOrders } = useActiveOrders();

  if (loadingDashboard) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Spinner size="lg" />
      </div>
    );
  }

  if (errorDashboard || !dashboard) {
    return (
      <EmptyState
        title="Erro ao carregar dashboard"
        description="Não foi possível carregar os dados. Tente novamente."
      />
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Dashboard" />

      {/* KPI Cards */}
      <div className="grid grid-cols-4 gap-4">
        <KpiCard
          title="Pedidos hoje"
          value={dashboard.totalOrdersToday}
        />
        <KpiCard
          title="Faturamento hoje"
          value={formatCurrency(dashboard.revenueToday)}
        />
        <KpiCard
          title="Pedidos pendentes"
          value={dashboard.pendingOrders}
        />
        <KpiCard
          title="Entregadores disponíveis"
          value={dashboard.availableCouriers}
        />
      </div>

      {/* Gráficos */}
      <div className="grid grid-cols-2 gap-4">
        <TopProductsChart data={dashboard.topSellingProducts} />
      </div>

      {/* Pedidos ativos */}
      <div className="rounded-lg bg-white shadow-md">
        <div className="border-b border-gray-100 px-6 py-4">
          <h2 className="text-sm font-medium text-gray-700">Pedidos ativos</h2>
        </div>
        {loadingOrders ? (
          <div className="flex h-32 items-center justify-center">
            <Spinner />
          </div>
        ) : (
          <ActiveOrdersList orders={activeOrders} />
        )}
      </div>
    </div>
  );
}
