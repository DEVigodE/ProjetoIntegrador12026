import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import type { TopProduct } from '../hooks/dashboard.types';

interface TopProductsChartProps {
  data: TopProduct[];
}

const COLORS = ['#f97316', '#fb923c', '#fdba74', '#fed7aa', '#ffedd5'];

export default function TopProductsChart({ data }: TopProductsChartProps) {
  const top5 = data.slice(0, 5);

  return (
    <div className="rounded-xl border border-gray-200/70 bg-gradient-to-br from-white via-white to-orange-50/40 p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="mb-4 flex items-center justify-between">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-gray-500">
          Top 5 produtos mais vendidos
        </h3>
        <span className="rounded-full border border-orange-200/70 bg-orange-50 px-2 py-0.5 text-[11px] font-semibold text-orange-700">
          Quantidade
        </span>
      </div>
      <ResponsiveContainer width="100%" height={220}>
        <PieChart>
          <Pie
            data={top5}
            dataKey="totalQuantitySold"
            nameKey="productName"
            cx="50%"
            cy="50%"
            outerRadius={80}
            innerRadius={36}
            label={({ productName, percent }) =>
              `${productName} (${(percent * 100).toFixed(0)}%)`
            }
            labelLine={false}
          >
            {top5.map((_, index) => (
              <Cell key={index} fill={COLORS[index % COLORS.length]} />
            ))}
          </Pie>
          <Tooltip formatter={(value: number) => [value, 'Qtd']} />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
