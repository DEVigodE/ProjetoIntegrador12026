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
    <div className="rounded-lg bg-white p-6 shadow-md">
      <h3 className="mb-4 text-sm font-medium text-gray-500">Top 5 produtos mais vendidos</h3>
      <ResponsiveContainer width="100%" height={220}>
        <PieChart>
          <Pie
            data={top5}
            dataKey="totalQuantitySold"
            nameKey="productName"
            cx="50%"
            cy="50%"
            outerRadius={80}
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
