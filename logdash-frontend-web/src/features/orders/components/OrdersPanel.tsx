import OrderCard from './OrderCard';
import AudioAlert from '../../../components/shared/AudioAlert';
import { useOrderNotifications } from '../hooks/useOrderNotifications';
import type { Order, OrderStatus } from '../types/order.types';

interface KanbanColumn {
  status: OrderStatus[];
  label: string;
  step: number;
}

const COLUMNS: KanbanColumn[] = [
  { status: ['PENDING'], label: 'Pendente', step: 1 },
  { status: ['ACCEPTED'], label: 'Aceito', step: 2 },
  { status: ['PREPARING'], label: 'Em Preparo', step: 3 },
  { status: ['READY'], label: 'Pronto', step: 4 },
  { status: ['OUT_FOR_DELIVERY'], label: 'Saiu para Entrega', step: 5 },
];

interface OrdersPanelProps {
  orders: Order[];
  onOrderClick: (order: Order) => void;
  statusFilter?: OrderStatus | '';
}

export default function OrdersPanel({
  orders,
  onOrderClick,
  statusFilter = '',
}: OrdersPanelProps) {
  const { hasNewOrders } = useOrderNotifications(orders);

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
      <AudioAlert play={hasNewOrders} />
      {COLUMNS.map((col) => {
        const columnOrders = orders.filter((o) => col.status.includes(o.status));
        if (statusFilter && columnOrders.length === 0) {
          return null;
        }
        return (
          <div key={col.label} className="rounded-xl border border-gray-200/70 bg-white p-3 shadow-sm shadow-gray-200/40">
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-xs font-semibold uppercase tracking-wide text-gray-600">
                {col.label} ({col.step})
                <span className="ml-1 text-[11px] font-semibold text-gray-500 normal-case">
                  · {columnOrders.length} {columnOrders.length === 1 ? 'pedido' : 'pedidos'}
                </span>
              </h3>
            </div>
            <div className="space-y-3">
              {columnOrders.length === 0 ? (
                <p className="py-4 text-center text-xs text-gray-400">
                  Nenhum pedido
                </p>
              ) : (
                columnOrders.map((order) => (
                  <OrderCard
                    key={order.id}
                    order={order}
                    onClick={onOrderClick}
                  />
                ))
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
