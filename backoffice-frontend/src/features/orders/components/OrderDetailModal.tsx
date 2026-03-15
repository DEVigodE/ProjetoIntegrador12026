import Modal from '../../../components/ui/Modal';
import Badge from '../../../components/ui/Badge';
import Spinner from '../../../components/ui/Spinner';
import OrderTimeline from './OrderTimeline';
import OrderActions from './OrderActions';
import { getStatusLabel, getStatusColor } from '../../../utils/orderStatusLabel';
import { useOrder } from '../hooks/useOrder';
import type { Order, OrderStatus } from '../types/order.types';

interface OrderDetailModalProps {
  orderId: number | undefined;
  isOpen: boolean;
  onClose: () => void;
  onAccept: (id: number) => void;
  onReject: (id: number) => void;
  onUpdateStatus: (id: number, status: OrderStatus) => void;
  isActionLoading?: boolean;
}

export default function OrderDetailModal({
  orderId,
  isOpen,
  onClose,
  onAccept,
  onReject,
  onUpdateStatus,
  isActionLoading = false,
}: OrderDetailModalProps) {
  const { data: order, isLoading } = useOrder(isOpen ? orderId : undefined);

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={order ? `Pedido #${order.id}` : 'Pedido'}>
      {isLoading || !order ? (
        <div className="flex justify-center py-8">
          <Spinner />
        </div>
      ) : (
        <div className="space-y-5 max-h-[70vh] overflow-y-auto">
          {/* Status */}
          <div className="flex items-center gap-2">
            <span className="text-sm text-gray-500">Status:</span>
            <Badge variant={getStatusColor(order.status)}>
              {getStatusLabel(order.status)}
            </Badge>
          </div>

          {/* Cliente */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-1">Cliente</h4>
            <p className="text-sm text-gray-900">{order.customerName}</p>
            <p className="text-sm text-gray-600">{order.customerPhone}</p>
            {order.customerEmail && (
              <p className="text-sm text-gray-600">{order.customerEmail}</p>
            )}
          </div>

          {/* Endereco */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-1">Endereco de Entrega</h4>
            <p className="text-sm text-gray-900">
              {order.deliveryStreet}, {order.deliveryNumber}
              {order.deliveryComplement && ` - ${order.deliveryComplement}`}
            </p>
            <p className="text-sm text-gray-600">
              {order.deliveryNeighborhood}, {order.deliveryCity} - {order.deliveryState}
            </p>
            <p className="text-sm text-gray-600">CEP: {order.deliveryZipCode}</p>
          </div>

          {/* Itens */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-2">Itens</h4>
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-xs text-gray-500">
                  <th className="pb-1">Produto</th>
                  <th className="pb-1 text-center">Qtd</th>
                  <th className="pb-1 text-right">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                {order.items.map((item) => (
                  <tr key={item.id} className="border-b border-gray-100">
                    <td className="py-1.5 text-gray-900">{item.productName}</td>
                    <td className="py-1.5 text-center text-gray-600">{item.quantity}</td>
                    <td className="py-1.5 text-right text-gray-900">
                      {formatCurrency(item.subtotal)}
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr>
                  <td colSpan={2} className="pt-2 text-right font-semibold text-gray-700">
                    Total:
                  </td>
                  <td className="pt-2 text-right font-semibold text-gray-900">
                    {formatCurrency(order.totalAmount)}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          {/* Observacoes */}
          {order.notes && (
            <div>
              <h4 className="text-sm font-semibold text-gray-700 mb-1">Observacoes</h4>
              <p className="text-sm text-gray-600">{order.notes}</p>
            </div>
          )}

          {/* Motivo da recusa */}
          {order.rejectedReason && (
            <div>
              <h4 className="text-sm font-semibold text-red-600 mb-1">Motivo da Recusa</h4>
              <p className="text-sm text-gray-600">{order.rejectedReason}</p>
            </div>
          )}

          {/* Timeline */}
          <div>
            <h4 className="text-sm font-semibold text-gray-700 mb-2">Timeline</h4>
            <OrderTimeline currentStatus={order.status} />
          </div>

          {/* Chat placeholder */}
          <div className="rounded-lg border border-dashed border-gray-300 p-4 text-center">
            <svg
              className="mx-auto mb-2 h-8 w-8 text-gray-300"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <p className="text-sm text-gray-400">Chat disponivel em breve</p>
          </div>

          {/* Acoes */}
          <div className="border-t pt-4">
            <OrderActions
              status={order.status}
              onAccept={() => onAccept(order.id)}
              onReject={() => onReject(order.id)}
              onUpdateStatus={(status) => onUpdateStatus(order.id, status)}
              isLoading={isActionLoading}
            />
          </div>
        </div>
      )}
    </Modal>
  );
}
