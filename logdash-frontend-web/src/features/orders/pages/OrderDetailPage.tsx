import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import Badge from '../../../components/ui/Badge';
import EmptyState from '../../../components/ui/EmptyState';
import OrderTimeline from '../components/OrderTimeline';
import OrderActions from '../components/OrderActions';
import RejectOrderModal from '../components/RejectOrderModal';
import ChatPanel from '../../chat/components/ChatPanel';
import DeliveryMiniMap from '../components/DeliveryMiniMap';
import { useOrder } from '../hooks/useOrder';
import { useAcceptOrder } from '../hooks/useAcceptOrder';
import { useRejectOrder } from '../hooks/useRejectOrder';
import { useUpdateOrderStatus } from '../hooks/useUpdateOrderStatus';
import { getStatusLabel, getStatusColor } from '../../../utils/orderStatusLabel';
import type { OrderStatus } from '../types/order.types';

export default function OrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const orderId = id ? Number(id) : undefined;
  const [showRejectModal, setShowRejectModal] = useState(false);

  const { data: order, isLoading, isError } = useOrder(orderId);
  const acceptOrder = useAcceptOrder();
  const rejectOrder = useRejectOrder();
  const updateStatus = useUpdateOrderStatus();

  const isActionLoading =
    acceptOrder.isPending || rejectOrder.isPending || updateStatus.isPending;

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

  function handleAccept() {
    if (!orderId) return;
    acceptOrder.mutate(orderId, {
      onSuccess: () => toast.success('Pedido aceito com sucesso.'),
      onError: () => toast.error('Erro ao aceitar pedido.'),
    });
  }

  function handleConfirmReject(reason: string) {
    if (!orderId) return;
    rejectOrder.mutate(
      { id: orderId, reason },
      {
        onSuccess: () => {
          toast.success('Pedido recusado.');
          setShowRejectModal(false);
        },
        onError: () => toast.error('Erro ao recusar pedido.'),
      }
    );
  }

  function handleUpdateStatus(status: OrderStatus) {
    if (!orderId) return;
    updateStatus.mutate(
      { id: orderId, status },
      {
        onSuccess: () => toast.success('Status atualizado com sucesso.'),
        onError: () => toast.error('Erro ao atualizar status.'),
      }
    );
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner size="lg" />
      </div>
    );
  }

  if (isError || !order) {
    return (
      <EmptyState
        title="Pedido nao encontrado"
        description="O pedido solicitado nao existe ou foi removido."
      />
    );
  }

  return (
    <>
      <PageHeader
        title={`Pedido #${order.id}`}
        breadcrumbs={[
          { label: 'Pedidos', path: '/orders' },
          { label: `#${order.id}` },
        ]}
      />

      <div className="grid grid-cols-3 gap-6">
        {/* Main content */}
        <div className="col-span-2 space-y-6">
          {/* Status + Acoes */}
          <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <h2 className="text-sm font-semibold uppercase tracking-wide text-gray-600">Status</h2>
                <Badge variant={getStatusColor(order.status)}>
                  {getStatusLabel(order.status)}
                </Badge>
              </div>
              <OrderActions
                status={order.status}
                onAccept={handleAccept}
                onReject={() => setShowRejectModal(true)}
                onUpdateStatus={handleUpdateStatus}
                isLoading={isActionLoading}
              />
            </div>
          </div>

          {/* Itens */}
          <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
            <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-gray-600">Itens do Pedido</h2>
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 text-left text-[11px] font-semibold uppercase tracking-wide text-gray-500">
                  <th className="pb-2">Produto</th>
                  <th className="pb-2 text-center">Qtd</th>
                  <th className="pb-2 text-right">Preco Unit.</th>
                  <th className="pb-2 text-right">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                {order.items.map((item) => (
                  <tr key={item.id} className="border-b border-gray-100">
                    <td className="py-2 text-gray-900">{item.productName}</td>
                    <td className="py-2 text-center text-gray-600">{item.quantity}</td>
                    <td className="py-2 text-right text-gray-600">
                      {formatCurrency(item.unitPrice)}
                    </td>
                    <td className="py-2 text-right text-gray-900">
                      {formatCurrency(item.subtotal)}
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr>
                  <td colSpan={3} className="pt-3 text-right font-semibold text-gray-700">
                    Total:
                  </td>
                  <td className="pt-3 text-right text-lg font-bold text-gray-900">
                    {formatCurrency(order.totalAmount)}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          {/* Observacoes */}
          {order.notes && (
            <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
              <h2 className="mb-2 text-sm font-semibold uppercase tracking-wide text-gray-600">Observacoes</h2>
              <p className="text-sm text-gray-600">{order.notes}</p>
            </div>
          )}

          {/* Motivo da recusa */}
          {order.rejectedReason && (
            <div className="rounded-xl border border-red-200 bg-red-50/80 p-6 shadow-[0_12px_30px_-16px_rgba(185,28,28,0.35)]">
              <h2 className="mb-2 text-sm font-semibold uppercase tracking-wide text-red-700">Motivo da Recusa</h2>
              <p className="text-sm text-red-600">{order.rejectedReason}</p>
            </div>
          )}

          {/* Minimapa do entregador */}
          {order.status === 'OUT_FOR_DELIVERY' && (
            <DeliveryMiniMap orderId={order.id} />
          )}

          {/* Chat */}
          <ChatPanel orderId={order.id} />
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Cliente */}
          <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
            <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-600">Cliente</h2>
            <div className="space-y-2 text-sm">
              <p className="font-medium text-gray-900">{order.customerName}</p>
              <p className="text-gray-600">{order.customerPhone}</p>
              {order.customerEmail && (
                <p className="text-gray-600">{order.customerEmail}</p>
              )}
            </div>
          </div>

          {/* Endereco */}
          <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
            <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-600">Endereco de Entrega</h2>
            <div className="space-y-1 text-sm">
              <p className="text-gray-900">
                {order.deliveryStreet}, {order.deliveryNumber}
                {order.deliveryComplement && ` - ${order.deliveryComplement}`}
              </p>
              <p className="text-gray-600">
                {order.deliveryNeighborhood}, {order.deliveryCity} - {order.deliveryState}
              </p>
              <p className="text-gray-600">CEP: {order.deliveryZipCode}</p>
            </div>
          </div>

          {/* Timeline */}
          <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
            <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-gray-600">Timeline</h2>
            <OrderTimeline currentStatus={order.status} />
          </div>
        </div>
      </div>

      <RejectOrderModal
        isOpen={showRejectModal}
        onClose={() => setShowRejectModal(false)}
        onConfirm={handleConfirmReject}
        loading={rejectOrder.isPending}
      />
    </>
  );
}
