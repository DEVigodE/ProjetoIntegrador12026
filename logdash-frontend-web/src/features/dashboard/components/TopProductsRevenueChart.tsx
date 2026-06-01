import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import type { TopProduct } from '../hooks/dashboard.types';

interface TopProductsRevenueChartProps {
  data: TopProduct[];
}

const COLORS = ['#f97316', '#fb923c', '#fdba74', '#fed7aa', '#ffedd5'];

function formatCurrency(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function TopProductsRevenueChart({ data }: TopProductsRevenueChartProps) {
  const top5 = data.slice(0, 5);

  const renderTooltip = (props: any) => {
    const { active, payload } = props as { active?: boolean; payload?: Array<{ payload?: TopProduct; value?: number }> };
    if (!active || !payload?.length) return null;

    const item = payload[0]?.payload;
    const revenue = payload[0]?.value ?? 0;

    return (
      <div className="rounded-lg border border-gray-200 bg-white px-3 py-2 shadow-md">
        <p className="text-xs font-semibold text-black">{item?.productName ?? 'Produto'}</p>
        <p className="text-xs text-black">Faturamento: {formatCurrency(Number(revenue))}</p>
      </div>
    );
  };

  return (
    <div className="rounded-xl border border-gray-200/70 bg-gradient-to-br from-white via-white to-orange-50/40 p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="mb-4 flex items-center justify-between">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-gray-500">
          Participação dos produtos no faturamento
        </h3>
        <span className="rounded-full border border-orange-200/70 bg-orange-50 px-2 py-0.5 text-[11px] font-semibold text-orange-700">
          BRL
        </span>
      </div>
      <div className="flex flex-col gap-4 lg:flex-row lg:items-center">
        <div className="h-[250px] w-full lg:w-[55%]">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={top5}
                dataKey="totalRevenue"
                nameKey="productName"
                cx="50%"
                cy="50%"
                outerRadius={84}
                innerRadius={46}
                paddingAngle={2}
                labelLine={false}
              >
                {top5.map((entry, index) => (
                  <Cell key={entry.productId} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip content={renderTooltip} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="grid flex-1 grid-cols-1 gap-2 text-xs text-black sm:grid-cols-2 lg:grid-cols-1">
          {top5.map((item, index) => (
            <div key={item.productId} className="flex items-center gap-2 rounded-lg bg-white/70 px-2 py-1.5 text-black">
              <span
                className="h-3 w-3 shrink-0 rounded-sm"
                style={{ backgroundColor: COLORS[index % COLORS.length] }}
                aria-hidden="true"
              />
              <span className="truncate">{item.productName}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}