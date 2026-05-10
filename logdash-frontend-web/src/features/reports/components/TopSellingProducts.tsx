import type { TopProduct } from '../types/report.types';

interface TopSellingProductsProps {
  products: TopProduct[];
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function TopSellingProducts({ products }: TopSellingProductsProps) {
  return (
    <div className="rounded-xl border border-gray-200/70 bg-white shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="border-b border-gray-100 bg-gray-50/60 px-6 py-4">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-gray-600">Top Produtos Mais Vendidos</h3>
      </div>
      {products.length === 0 ? (
        <div className="px-6 py-8 text-center">
          <p className="text-sm text-gray-400">Nenhum dado disponivel</p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50/70 text-left text-[11px] font-semibold uppercase tracking-wide text-gray-500">
                <th className="w-12 px-6 py-3">#</th>
                <th className="px-6 py-3">Produto</th>
                <th className="px-6 py-3 text-right">Qtd Vendida</th>
                <th className="px-6 py-3 text-right">Receita</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product, index) => (
                <tr key={product.productId} className="border-b border-gray-100 hover:bg-gray-50/60">
                  <td className="px-6 py-3 font-semibold text-gray-500">{index + 1}</td>
                  <td className="px-6 py-3 text-gray-900">{product.productName}</td>
                  <td className="px-6 py-3 text-right text-gray-900">{product.totalQuantitySold}</td>
                  <td className="px-6 py-3 text-right text-gray-900">{formatCurrency(product.totalRevenue)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
