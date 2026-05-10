import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import type { SalesByDay } from '../hooks/dashboard.types';

interface SalesChartProps {
  data: SalesByDay[];
}

function formatCurrency(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function SalesChart({ data }: SalesChartProps) {
  const formatted = data.map((d) => ({
    ...d,
    label: format(parseISO(d.date), 'dd/MM', { locale: ptBR }),
  }));

  return (
    <div className="rounded-xl border border-gray-200/70 bg-gradient-to-br from-white via-white to-orange-50/40 p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="mb-4 flex items-center justify-between">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-gray-500">
          Vendas — ultimos 7 dias
        </h3>
        <span className="rounded-full border border-orange-200/70 bg-orange-50 px-2 py-0.5 text-[11px] font-semibold text-orange-700">
          BRL
        </span>
      </div>
      <ResponsiveContainer width="100%" height={220}>
        <BarChart data={formatted} margin={{ top: 0, right: 0, left: 10, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
          <XAxis dataKey="label" tick={{ fontSize: 12, fill: '#6b7280' }} axisLine={false} tickLine={false} />
          <YAxis
            tickFormatter={(v) => `R$${v}`}
            tick={{ fontSize: 12, fill: '#6b7280' }}
            width={60}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip formatter={(value: number) => [formatCurrency(value), 'Total']} />
          <Bar dataKey="total" fill="#fb923c" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
