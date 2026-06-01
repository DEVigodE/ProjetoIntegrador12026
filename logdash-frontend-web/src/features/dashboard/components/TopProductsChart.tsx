import {
  BarChart,
  Bar,
  CartesianGrid,
  XAxis,
  YAxis,
  LabelList,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import type { TopProduct } from '../hooks/dashboard.types';

interface TopProductsChartProps {
  data: TopProduct[];
}

export default function TopProductsChart({ data }: TopProductsChartProps) {
  const top5 = data.slice(0, 5);
  const maxQuantity = Math.max(...top5.map((item) => item.totalQuantitySold), 0);
  const axisMax = Math.max(4, Math.ceil(maxQuantity));
  const axisTicks = Array.from({ length: axisMax + 1 }, (_, index) => index);

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
      <ResponsiveContainer width="100%" height={240}>
        <BarChart data={top5} layout="vertical" margin={{ top: 8, right: 28, left: 8, bottom: 8 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
          <XAxis
            type="number"
            domain={[0, axisMax]}
            ticks={axisTicks}
            allowDecimals={false}
            tick={false}
            axisLine={false}
            tickLine={false}
            height={34}
            interval={0}
          />
          <YAxis
            type="category"
            dataKey="productName"
            width={132}
            tick={{ fill: '#000000', fontSize: 12 }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip formatter={(value, _name, props) => [value, props.payload?.productName ?? 'Quantidade']} contentStyle={{ color: '#000000' }} labelStyle={{ color: '#000000' }} />
          <Bar dataKey="totalQuantitySold" fill="#f97316" radius={[0, 8, 8, 0]} barSize={18} minPointSize={6}>
            <LabelList dataKey="totalQuantitySold" position="right" fill="#000000" fontSize={12} />
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
