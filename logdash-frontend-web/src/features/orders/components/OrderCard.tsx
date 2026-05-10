import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import Badge from '../../../components/ui/Badge';
import { getStatusLabel, getStatusColor } from '../../../utils/orderStatusLabel';
import type { Order } from '../types/order.types';

interface OrderCardProps {
  order: Order;
  onClick: (order: Order) => void;
}

export default function OrderCard({ order, onClick }: OrderCardProps) {
  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

  const timeAgo = formatDistanceToNow(new Date(order.createdAt), {
    addSuffix: true,
    locale: ptBR,
  });

  return (
    <button
      type="button"
      onClick={() => onClick(order)}
      className="w-full rounded-xl border border-gray-200/70 bg-white p-4 text-left shadow-md shadow-gray-200/60 transition-shadow hover:shadow-lg"
    >
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-semibold text-gray-900">#{order.id}</span>
        <Badge variant={getStatusColor(order.status)}>
          {getStatusLabel(order.status)}
        </Badge>
      </div>
      <p className="text-sm text-gray-700 truncate">{order.customerName}</p>
      <div className="mt-2 flex items-center justify-between">
        <span className="text-sm font-medium text-gray-900">
          {formatCurrency(order.totalAmount)}
        </span>
        <span className="text-xs text-gray-500">{timeAgo}</span>
      </div>
    </button>
  );
}
