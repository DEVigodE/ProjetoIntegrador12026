import { useState, useEffect } from 'react';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import Pagination from '../../../components/ui/Pagination';
import Table, { type Column } from '../../../components/ui/Table';
import Badge from '../../../components/ui/Badge';
import OrdersPanel from '../components/OrdersPanel';
import OrderFilters from '../components/OrderFilters';
import OrderDetailModal from '../components/OrderDetailModal';
import RejectOrderModal from '../components/RejectOrderModal';
import { useActiveOrders } from '../hooks/useActiveOrders';
import { useOrders } from '../hooks/useOrders';
import { useAcceptOrder } from '../hooks/useAcceptOrder';
import { useRejectOrder } from '../hooks/useRejectOrder';
import { useUpdateOrderStatus } from '../hooks/useUpdateOrderStatus';
import { getStatusLabel, getStatusColor } from '../../../utils/orderStatusLabel';
import { useOrderNotificationStore } from '../../../store/orderNotificationStore';
import type { Order, OrderStatus } from '../types/order.types';

type ViewMode = 'kanban' | 'list';

export default function OrdersPage() {
  const [view, setView] = useState<ViewMode>('kanban');
  const [selectedOrderId, setSelectedOrderId] = useState<number | undefined>();
  const [rejectOrderId, setRejectOrderId] = useState<number | undefined>();
  const [statusFilter, setStatusFilter] = useState<OrderStatus | ''>('');
  const [page, setPage] = useState(0);
  const clearNotifications = useOrderNotificationStore((s) => s.clear);

  useEffect(() => {
    clearNotifications();
  }, [clearNotifications]);

  const { data: activeOrders, isLoading: loadingActive } = useActiveOrders();
  const { data: ordersPage, isLoading: loadingList } = useOrders({
    page,
    size: 20,
    status: statusFilter || undefined,
  });
  const filteredActiveOrders = statusFilter
    ? activeOrders?.filter((order) => order.status === statusFilter)
    : activeOrders;

  const acceptOrder = useAcceptOrder();
  const rejectOrder = useRejectOrder();
  const updateStatus = useUpdateOrderStatus();

  const isActionLoading =
    acceptOrder.isPending || rejectOrder.isPending || updateStatus.isPending;

  function handleAccept(id: number) {
    acceptOrder.mutate(id, {
      onSuccess: () => {
        toast.success('Pedido aceito com sucesso.');
        setSelectedOrderId(undefined);
      },
      onError: () => toast.error('Erro ao aceitar pedido.'),
    });
  }

  function handleReject(id: number) {
    setSelectedOrderId(undefined);
    setRejectOrderId(id);
  }

  function handleConfirmReject(reason: string) {
    if (!rejectOrderId) return;
    rejectOrder.mutate(
      { id: rejectOrderId, reason },
      {
        onSuccess: () => {
          toast.success('Pedido recusado.');
          setRejectOrderId(undefined);
        },
        onError: () => toast.error('Erro ao recusar pedido.'),
      }
    );
  }

  function handleUpdateStatus(id: number, status: OrderStatus) {
    updateStatus.mutate(
      { id, status },
      {
        onSuccess: () => {
          toast.success('Status atualizado com sucesso.');
          setSelectedOrderId(undefined);
        },
        onError: () => toast.error('Erro ao atualizar status.'),
      }
    );
  }

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

  const listColumns = [
    { key: 'id', header: '#', sortable: true, render: (o) => `#${o.id}` },
    { key: 'customerName', header: 'Cliente', sortable: true },
    {
      key: 'status',
      header: 'Status',
      render: (o) => (
        <Badge variant={getStatusColor(o.status)}>{getStatusLabel(o.status)}</Badge>
      ),
    },
    {
      key: 'totalAmount',
      header: 'Total',
      sortable: true,
      render: (o) => formatCurrency(o.totalAmount),
    },
    {
      key: 'createdAt',
      header: 'Criado em',
      sortable: true,
      render: (o) =>
        new Date(o.createdAt).toLocaleString('pt-BR', {
          day: '2-digit',
          month: '2-digit',
          hour: '2-digit',
          minute: '2-digit',
        }),
    },
  ] satisfies Column<Order>[];

  return (
    <>
      <PageHeader title="Pedidos" />

      {/* Tabs */}
      <div className="mb-6 inline-flex gap-1 rounded-xl border border-gray-200/70 bg-white p-1 shadow-sm shadow-gray-200/40">
        <button
          type="button"
          className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
            view === 'kanban'
              ? 'bg-orange-50 text-orange-700 shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
          onClick={() => setView('kanban')}
        >
          Kanban
        </button>
        <button
          type="button"
          className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
            view === 'list'
              ? 'bg-orange-50 text-orange-700 shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
          onClick={() => setView('list')}
        >
          Lista
        </button>
      </div>

      {/* Kanban View */}
      {view === 'kanban' && (
        <>
          <div className="mb-4">
            <OrderFilters
              status={statusFilter}
              onStatusChange={(s) => setStatusFilter(s)}
            />
          </div>
          {loadingActive ? (
            <div className="flex justify-center py-12">
              <Spinner size="lg" />
            </div>
          ) : !filteredActiveOrders || filteredActiveOrders.length === 0 ? (
            <EmptyState
              title="Nenhum pedido ativo"
              description="Novos pedidos aparecerão aqui automaticamente."
            />
          ) : (
            <OrdersPanel
              orders={filteredActiveOrders}
              statusFilter={statusFilter}
              onOrderClick={(order) => setSelectedOrderId(order.id)}
            />
          )}
        </>
      )}

      {/* List View */}
      {view === 'list' && (
        <>
          <div className="mb-4">
            <OrderFilters
              status={statusFilter}
              onStatusChange={(s) => {
                setStatusFilter(s);
                setPage(0);
              }}
            />
          </div>
          {loadingList ? (
            <div className="flex justify-center py-12">
              <Spinner size="lg" />
            </div>
          ) : !ordersPage || ordersPage.content.length === 0 ? (
            <EmptyState
              title="Nenhum pedido encontrado"
              description="Ajuste os filtros ou aguarde novos pedidos."
            />
          ) : (
            <>
              <Table
                columns={listColumns}
                data={ordersPage.content}
                keyExtractor={(o) => o.id}
                onRowClick={(order) => setSelectedOrderId(order.id)}
              />
              <div className="mt-4">
                <Pagination
                  currentPage={page + 1}
                  totalPages={ordersPage.totalPages}
                  onPageChange={(p) => setPage(p - 1)}
                />
              </div>
            </>
          )}
        </>
      )}

      {/* Detail Modal */}
      <OrderDetailModal
        orderId={selectedOrderId}
        isOpen={!!selectedOrderId}
        onClose={() => setSelectedOrderId(undefined)}
        onAccept={handleAccept}
        onReject={handleReject}
        onUpdateStatus={handleUpdateStatus}
        isActionLoading={isActionLoading}
      />

      {/* Reject Modal */}
      <RejectOrderModal
        isOpen={!!rejectOrderId}
        onClose={() => setRejectOrderId(undefined)}
        onConfirm={handleConfirmReject}
        loading={rejectOrder.isPending}
      />
    </>
  );
}
