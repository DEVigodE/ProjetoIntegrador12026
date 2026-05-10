import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import StatusBadge from './StatusBadge';

interface OrderCardOrder {
  id: number;
  customerName: string;
  totalAmount: number;
  status: 'PENDING' | 'ACCEPTED' | 'PREPARING' | 'READY' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED';
  createdAt: string;
}

interface OrderCardProps {
  order: OrderCardOrder;
  onClick?: (order: OrderCardOrder) => void;
}

export default function OrderCard({ order, onClick }: OrderCardProps) {
  const timeAgo = formatDistanceToNow(new Date(order.createdAt), {
    addSuffix: true,
    locale: ptBR,
  });

  const formattedValue = new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(order.totalAmount);

  return (
    <div
      className={`rounded-xl border border-gray-200/70 bg-white p-4 shadow-md shadow-gray-200/60 transition-shadow ${
        onClick ? 'cursor-pointer hover:shadow-lg' : ''
      }`}
      onClick={onClick ? () => onClick(order) : undefined}
    >
      <div className="flex items-center justify-between">
        <span className="text-sm font-semibold text-gray-900">
          Pedido #{order.id}
        </span>
        <StatusBadge status={order.status} />
      </div>
      <p className="mt-1 text-sm text-gray-700">{order.customerName}</p>
      <div className="mt-2 flex items-center justify-between">
        <span className="text-sm font-medium text-gray-900">{formattedValue}</span>
        <span className="text-xs text-gray-500">{timeAgo}</span>
      </div>
    </div>
  );
}
