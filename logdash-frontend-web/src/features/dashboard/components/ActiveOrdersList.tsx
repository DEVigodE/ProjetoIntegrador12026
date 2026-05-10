import { useNavigate } from 'react-router-dom';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import StatusBadge from '../../../components/shared/StatusBadge';
import EmptyState from '../../../components/ui/EmptyState';
import type { Order } from '../../orders/types/order.types';

interface ActiveOrdersListProps {
  orders: Order[];
}

function formatCurrency(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function ActiveOrdersList({ orders }: ActiveOrdersListProps) {
  const navigate = useNavigate();

  if (orders.length === 0) {
    return <EmptyState title="Nenhum pedido ativo" description="Todos os pedidos foram concluídos." />;
  }

  return (
    <div className="overflow-hidden rounded-xl border border-gray-200/70 bg-white shadow-md shadow-gray-200/60">
      <div className="grid grid-cols-[80px_1fr_140px_120px_140px] gap-4 border-b border-gray-100 px-4 py-2 text-[12px] font-semibold uppercase tracking-wide text-gray-500">
        <span>#</span>
        <span>Cliente</span>
        <span>Status</span>
        <span>Total</span>
        <span>Data do Pedido</span>
      </div>
      <div className="divide-y divide-gray-100">
        {orders.map((order) => (
          <button
            key={order.id}
            onClick={() => navigate(`/orders/${order.id}`)}
            className="grid w-full grid-cols-[80px_1fr_140px_120px_140px] gap-4 px-4 py-3 text-left text-sm text-gray-700 hover:bg-gray-50/70 transition-colors"
          >
            <span className="text-gray-900">#{order.id}</span>
            <span className="text-[15px] font-semibold text-gray-900">{order.customerName}</span>
            <div>
              <StatusBadge status={order.status} />
            </div>
            <span className="text-gray-900">{formatCurrency(order.totalAmount)}</span>
            <span className="text-gray-500">
              {formatDistanceToNow(parseISO(order.createdAt), { addSuffix: true, locale: ptBR })}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}
