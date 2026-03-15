import OrderCard from './OrderCard';
import type { Order, OrderStatus } from '../types/order.types';
import { getStatusLabel } from '../../../utils/orderStatusLabel';

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
  return (
    <div className="grid grid-cols-4 gap-4">
      {COLUMNS.map((col) => {
        const columnOrders = orders.filter((o) => col.status.includes(o.status));
        return (
          <div key={col.label} className="rounded-lg bg-gray-50 p-3">
            <div className="mb-3 flex items-center justify-between">
              <h3 className="text-sm font-semibold text-gray-700">{col.label}</h3>
              <span className="rounded-full bg-gray-200 px-2 py-0.5 text-xs font-medium text-gray-600">
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
