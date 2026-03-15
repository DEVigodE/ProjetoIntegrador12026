import { useState } from 'react';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Button from '../../../components/ui/Button';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import Modal from '../../../components/ui/Modal';
import CourierTable from '../components/CourierTable';
import CourierForm, { type CourierFormData } from '../components/CourierForm';
import { useCouriers } from '../hooks/useCouriers';
import { useCreateCourier } from '../hooks/useCreateCourier';
import { useUpdateCourier } from '../hooks/useUpdateCourier';
import type { Courier } from '../types/delivery.types';

export default function CouriersPage() {
  const [showForm, setShowForm] = useState(false);
  const [editingCourier, setEditingCourier] = useState<Courier | undefined>();

  const { data: couriers, isLoading, isError } = useCouriers();
  const createCourier = useCreateCourier();
  const updateCourier = useUpdateCourier();

  function handleOpenCreate() {
    setEditingCourier(undefined);
    setShowForm(true);
  }

  function handleOpenEdit(courier: Courier) {
    setEditingCourier(courier);
    setShowForm(true);
  }

  function handleClose() {
    setShowForm(false);
    setEditingCourier(undefined);
  }

  function handleSubmit(data: CourierFormData) {
    const payload = {
      ...data,
      email: data.email || undefined,
      vehicleType: data.vehicleType || undefined,
      vehiclePlate: data.vehiclePlate || undefined,
    };

    if (editingCourier) {
      updateCourier.mutate(
        { ...payload, id: editingCourier.id, active: editingCourier.active },
        {
          onSuccess: () => {
            toast.success('Entregador atualizado com sucesso.');
            handleClose();
          },
          onError: () => toast.error('Erro ao atualizar entregador.'),
        }
      );
    } else {
      createCourier.mutate(payload, {
        onSuccess: () => {
          toast.success('Entregador criado com sucesso.');
          handleClose();
        },
        onError: () => toast.error('Erro ao criar entregador.'),
      });
    }
  }

  function handleToggleActive(courier: Courier) {
    updateCourier.mutate(
      {
        id: courier.id,
        name: courier.name,
        phone: courier.phone,
        email: courier.email,
        vehicleType: courier.vehicleType,
        vehiclePlate: courier.vehiclePlate,
        active: !courier.active,
      },
      {
        onError: () => toast.error('Erro ao alterar status do entregador.'),
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
        title="Erro ao carregar entregadores"
        description="Tente novamente mais tarde."
      />
    );
  }

  return (
    <>
      <div className="flex items-center justify-between">
        <PageHeader title="Entregadores" />
        <Button onClick={handleOpenCreate}>Novo Entregador</Button>
      </div>

      {!couriers || couriers.length === 0 ? (
        <EmptyState
          title="Nenhum entregador cadastrado"
          description="Cadastre seu primeiro entregador clicando no botao acima."
        />
      ) : (
        <CourierTable
          couriers={couriers}
          onEdit={handleOpenEdit}
          onToggleActive={handleToggleActive}
        />
      )}

      <Modal
        isOpen={showForm}
        onClose={handleClose}
        title={editingCourier ? 'Editar Entregador' : 'Novo Entregador'}
      >
        <CourierForm
          courier={editingCourier}
          onSubmit={handleSubmit}
          onCancel={handleClose}
          isSubmitting={createCourier.isPending || updateCourier.isPending}
        />
      </Modal>
    </>
  );
}
