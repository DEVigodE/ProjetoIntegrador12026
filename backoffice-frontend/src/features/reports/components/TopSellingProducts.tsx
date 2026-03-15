import type { TopProduct } from '../types/report.types';

interface TopSellingProductsProps {
  products: TopProduct[];
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function TopSellingProducts({ products }: TopSellingProductsProps) {
  return (
    <div className="rounded-lg bg-white shadow-sm border border-gray-200">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900">Top Produtos Mais Vendidos</h3>
      </div>
      {products.length === 0 ? (
        <div className="px-6 py-8 text-center">
          <p className="text-sm text-gray-400">Nenhum dado disponivel</p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50 text-left text-xs uppercase text-gray-500">
                <th className="px-6 py-3 w-12">#</th>
                <th className="px-6 py-3">Produto</th>
                <th className="px-6 py-3 text-right">Qtd Vendida</th>
                <th className="px-6 py-3 text-right">Receita</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product, index) => (
                <tr key={product.productId} className="border-b border-gray-100">
                  <td className="px-6 py-3 font-medium text-gray-500">{index + 1}</td>
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
