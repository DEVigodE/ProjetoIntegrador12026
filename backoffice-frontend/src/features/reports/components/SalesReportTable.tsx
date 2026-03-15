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
    <div className="rounded-lg bg-white shadow-sm border border-gray-200">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">
          Vendas: {formatDate(data.startDate)} a {formatDate(data.endDate)}
        </h3>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b bg-gray-50 text-left text-xs uppercase text-gray-500">
              <th className="px-6 py-3">Metrica</th>
              <th className="px-6 py-3 text-right">Valor</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-b border-gray-100">
              <td className="px-6 py-3 text-gray-900">Total de Pedidos</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.totalOrders}</td>
            </tr>
            <tr className="border-b border-gray-100">
              <td className="px-6 py-3 text-gray-900">Faturamento Total</td>
              <td className="px-6 py-3 text-right text-gray-900">{formatCurrency(data.totalRevenue)}</td>
            </tr>
            <tr className="border-b border-gray-100">
              <td className="px-6 py-3 text-gray-900">Ticket Medio</td>
              <td className="px-6 py-3 text-right text-gray-900">{formatCurrency(data.averageOrderValue)}</td>
            </tr>
            <tr className="border-b border-gray-100">
              <td className="px-6 py-3 text-gray-900">Pedidos Entregues</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.deliveredOrders}</td>
            </tr>
            <tr>
              <td className="px-6 py-3 text-gray-900">Pedidos Cancelados</td>
              <td className="px-6 py-3 text-right text-gray-900">{data.cancelledOrders}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
