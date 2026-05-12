import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import StatusBadge from '../../../components/shared/StatusBadge';
import EmptyState from '../../../components/ui/EmptyState';
import Select from '../../../components/ui/Select';
import type { Order } from '../../orders/types/order.types';

interface ActiveOrdersListProps {
  orders: Order[];
}

type SortOption = 'date_desc' | 'date_asc' | 'value_desc' | 'value_asc' | 'status_flow';

const sortOptions = [
  { value: 'date_desc', label: 'Data (mais recente)' },
  { value: 'date_asc', label: 'Data (mais antiga)' },
  { value: 'value_desc', label: 'Valor (maior)' },
  { value: 'value_asc', label: 'Valor (menor)' },
  { value: 'status_flow', label: 'Status (fluxo)' },
];

const statusOrder: Order['status'][] = [
  'PENDING',
  'ACCEPTED',
  'PREPARING',
  'READY',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
];

function formatCurrency(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

export default function ActiveOrdersList({ orders }: ActiveOrdersListProps) {
  const navigate = useNavigate();
  const [sort, setSort] = useState<SortOption>('date_desc');

  const sortedOrders = useMemo(() => {
    const list = [...orders];

    switch (sort) {
      case 'date_asc':
        return list.sort(
          (a, b) => parseISO(a.createdAt).getTime() - parseISO(b.createdAt).getTime()
        );
      case 'value_desc':
        return list.sort((a, b) => b.totalAmount - a.totalAmount);
      case 'value_asc':
        return list.sort((a, b) => a.totalAmount - b.totalAmount);
      case 'status_flow':
        return list.sort((a, b) => {
          const aIndex = statusOrder.indexOf(a.status);
          const bIndex = statusOrder.indexOf(b.status);
          if (aIndex !== bIndex) return aIndex - bIndex;
          return parseISO(b.createdAt).getTime() - parseISO(a.createdAt).getTime();
        });
      case 'date_desc':
      default:
        return list.sort(
          (a, b) => parseISO(b.createdAt).getTime() - parseISO(a.createdAt).getTime()
        );
    }
  }, [orders, sort]);

  if (orders.length === 0) {
    return <EmptyState title="Nenhum pedido ativo" description="Todos os pedidos foram concluídos." />;
  }

  return (
    <div className="overflow-hidden rounded-xl border border-gray-200/70 bg-white shadow-md shadow-gray-200/60">
      <div className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-100 bg-gray-50/60 px-4 py-3">
        <span className="text-xs font-semibold uppercase tracking-wide text-gray-600">
          Ordenar por
        </span>
        <div className="w-60">
          <Select
            aria-label="Ordenar pedidos"
            value={sort}
            onChange={(event) => setSort(event.target.value as SortOption)}
            options={sortOptions}
          />
        </div>
      </div>
      <div className="grid grid-cols-[80px_1fr_140px_120px_140px] gap-4 border-b border-gray-100 px-4 py-2 text-[12px] font-semibold uppercase tracking-wide text-gray-500">
        <span>#</span>
        <span>Cliente</span>
        <span>Status</span>
        <span>Total</span>
        <span>Data do Pedido</span>
      </div>
      <div className="divide-y divide-gray-100">
        {sortedOrders.map((order) => (
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
