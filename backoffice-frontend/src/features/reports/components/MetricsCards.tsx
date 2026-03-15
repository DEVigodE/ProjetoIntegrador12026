import type { SalesReportData } from '../types/report.types';

interface MetricsCardsProps {
  data: SalesReportData;
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

interface CardProps {
  label: string;
  value: string;
}

function Card({ label, value }: CardProps) {
  return (
    <div className="rounded-lg bg-white p-5 shadow-sm border border-gray-200">
      <p className="text-sm text-gray-500">{label}</p>
      <p className="mt-1 text-2xl font-bold text-gray-900">{value}</p>
    </div>
  );
}

export default function MetricsCards({ data }: MetricsCardsProps) {
  return (
    <div className="grid grid-cols-5 gap-4">
      <Card label="Total Pedidos" value={String(data.totalOrders)} />
      <Card label="Faturamento" value={formatCurrency(data.totalRevenue)} />
      <Card label="Ticket Medio" value={formatCurrency(data.averageOrderValue)} />
      <Card label="Entregues" value={String(data.deliveredOrders)} />
      <Card label="Cancelados" value={String(data.cancelledOrders)} />
    </div>
  );
}
