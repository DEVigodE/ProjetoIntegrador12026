import type { SalesReportData } from '../types/report.types';

interface SalesReportTableProps {
  data: SalesReportData;
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

function formatDate(dateStr: string): string {
  return new Date(dateStr + 'T00:00:00').toLocaleDateString('pt-BR');
}

export default function SalesReportTable({ data }: SalesReportTableProps) {
  return (
    <div className="rounded-xl border border-gray-200/70 bg-white shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="border-b border-gray-100 bg-gray-50/60 px-6 py-4">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-gray-600">
          Vendas: {formatDate(data.startDate)} a {formatDate(data.endDate)}
        </h3>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-gray-100 bg-gray-50/70 text-left text-[11px] font-semibold uppercase tracking-wide text-gray-500">
              <th className="px-6 py-3">Metrica</th>
              <th className="px-6 py-3 text-right">Valor</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-gray-100 hover:bg-gray-50/60">
              <td className="px-6 py-3 text-gray-800">Total de Pedidos</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.totalOrders}</td>
            </tr>
            <tr className="border-b border-gray-100 hover:bg-gray-50/60">
              <td className="px-6 py-3 text-gray-800">Faturamento Total</td>
              <td className="px-6 py-3 text-right text-gray-900">{formatCurrency(data.totalRevenue)}</td>
            </tr>
            <tr className="border-b border-gray-100 hover:bg-gray-50/60">
              <td className="px-6 py-3 text-gray-800">Ticket Medio</td>
              <td className="px-6 py-3 text-right text-gray-900">{formatCurrency(data.averageOrderValue)}</td>
            </tr>
            <tr className="border-b border-gray-100 hover:bg-gray-50/60">
              <td className="px-6 py-3 text-gray-800">Pedidos Entregues</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.deliveredOrders}</td>
            </tr>
            <tr className="hover:bg-gray-50/60">
              <td className="px-6 py-3 text-gray-800">Pedidos Cancelados</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.cancelledOrders}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
