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
    <div className="divide-y divide-gray-100">
      {orders.map((order) => (
        <button
          key={order.id}
          onClick={() => navigate(`/orders/${order.id}`)}
          className="flex w-full items-center justify-between px-4 py-3 text-left hover:bg-gray-50 transition-colors"
        >
          <div className="flex items-center gap-4">
            <span className="text-sm font-medium text-gray-900">#{order.id}</span>
            <span className="text-sm text-gray-700">{order.customerName}</span>
            <StatusBadge status={order.status} />
          </div>
          <div className="flex items-center gap-4 text-sm text-gray-700">
            <span>{formatCurrency(order.totalAmount)}</span>
            <span>{formatDistanceToNow(parseISO(order.createdAt), { addSuffix: true, locale: ptBR })}</span>
          </div>
        </button>
      ))}
    </div>
  );
}
