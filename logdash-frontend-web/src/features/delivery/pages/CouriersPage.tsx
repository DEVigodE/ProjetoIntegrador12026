import { useState } from 'react';
import { toast } from 'react-toastify';
import { useKeycloak } from '@react-keycloak/web';
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
import { useToggleCourierActive } from '../hooks/useToggleCourierActive';
import type { Courier } from '../types/delivery.types';

export default function CouriersPage() {
  const [showForm, setShowForm] = useState(false);
  const [editingCourier, setEditingCourier] = useState<Courier | undefined>();

  const { keycloak } = useKeycloak();
  const userRoles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];
  const isAdmin = userRoles.includes('ADMIN');

  const { data: couriers, isLoading, isError } = useCouriers();
  const createCourier = useCreateCourier();
  const updateCourier = useUpdateCourier();
  const toggleCourierActive = useToggleCourierActive();

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
        { ...payload, id: editingCourier.id },
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
    toggleCourierActive.mutate(
      { id: courier.id, active: !courier.active },
      {
        onSuccess: () =>
          toast.success(`Entregador ${courier.active ? 'desativado' : 'ativado'} com sucesso.`),
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
          onToggleActive={handleToggleActive}
          canToggleActive={isAdmin}
          isSubmitting={createCourier.isPending || updateCourier.isPending}
        />
      </Modal>
    </>
  );
}
