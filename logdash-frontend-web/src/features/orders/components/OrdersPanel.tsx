import OrderCard from './OrderCard';
import AudioAlert from '../../../components/shared/AudioAlert';
import { useOrderNotifications } from '../hooks/useOrderNotifications';
import type { Order, OrderStatus } from '../types/order.types';

interface KanbanColumn {
  status: OrderStatus[];
  label: string;
}

const COLUMNS: KanbanColumn[] = [
  { status: ['PENDING'], label: 'Pendente' },
  { status: ['ACCEPTED', 'PREPARING'], label: 'Em Preparo' },
  { status: ['READY'], label: 'Pronto' },
  { status: ['OUT_FOR_DELIVERY'], label: 'Saiu para Entrega' },
];

interface OrdersPanelProps {
  orders: Order[];
  onOrderClick: (order: Order) => void;
}

export default function OrdersPanel({ orders, onOrderClick }: OrdersPanelProps) {
  const { hasNewOrders } = useOrderNotifications(orders);

  return (
    <div className="grid grid-cols-4 gap-4">
      <AudioAlert play={hasNewOrders} />
      {COLUMNS.map((col) => {
        const columnOrders = orders.filter((o) => col.status.includes(o.status));
        return (
          <div key={col.label} className="rounded-xl border border-gray-200/70 bg-white p-3 shadow-sm shadow-gray-200/40">
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-xs font-semibold uppercase tracking-wide text-gray-600">{col.label}</h3>
              <span className="rounded-full border border-gray-200 bg-gray-50 px-2 py-0.5 text-[11px] font-semibold text-gray-600">
                {columnOrders.length}
              </span>
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
