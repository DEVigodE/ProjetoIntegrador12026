import { useState } from 'react';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import DeliveryTable from '../components/DeliveryTable';
import AssignCourierModal from '../components/AssignCourierModal';
import { useDeliveries } from '../hooks/useDeliveries';
import { useAssignCourier } from '../hooks/useAssignCourier';
import type { Delivery } from '../types/delivery.types';

export default function DeliveriesPage() {
  const [assignDelivery, setAssignDelivery] = useState<Delivery | null>(null);

  const { data: deliveries, isLoading, isError } = useDeliveries();
  const assignCourier = useAssignCourier();

  function handleAssign(courierId: number) {
    if (!assignDelivery) return;
    assignCourier.mutate(
      { deliveryId: assignDelivery.id, courierId },
      {
        onSuccess: () => {
          toast.success('Entregador atribuido com sucesso.');
          setAssignDelivery(null);
        },
        onError: () => toast.error('Erro ao atribuir entregador.'),
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

  if (isError) {
    return (
      <EmptyState
        title="Erro ao carregar entregas"
        description="Tente novamente mais tarde."
      />
    );
  }

  return (
    <>
      <PageHeader title="Entregas" />

      {!deliveries || deliveries.length === 0 ? (
        <EmptyState
          title="Nenhuma entrega ativa"
          description="Entregas aparecerao aqui quando pedidos forem enviados."
        />
      ) : (
        <DeliveryTable
          deliveries={deliveries}
          onAssign={setAssignDelivery}
        />
      )}

      <AssignCourierModal
        isOpen={!!assignDelivery}
        onClose={() => setAssignDelivery(null)}
        onConfirm={handleAssign}
        loading={assignCourier.isPending}
      />
    </>
  );
}
