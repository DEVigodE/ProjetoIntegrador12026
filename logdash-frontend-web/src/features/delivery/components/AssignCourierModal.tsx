import { useState } from 'react';
import Modal from '../../../components/ui/Modal';
import Button from '../../../components/ui/Button';
import Spinner from '../../../components/ui/Spinner';
import CourierStatusBadge from './CourierStatusBadge';
import { useAvailableCouriers } from '../hooks/useAvailableCouriers';

interface AssignCourierModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (courierId: number) => void;
  loading: boolean;
}

export default function AssignCourierModal({
  isOpen,
  onClose,
  onConfirm,
  loading,
}: AssignCourierModalProps) {
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const { data: couriers, isLoading } = useAvailableCouriers(isOpen);

  function handleClose() {
    setSelectedId(null);
    onClose();
  }

  function handleConfirm() {
    if (selectedId) {
      onConfirm(selectedId);
      setSelectedId(null);
    }
  }

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Atribuir Entregador">
      {isLoading ? (
        <div className="flex justify-center py-8">
          <Spinner />
        </div>
      ) : !couriers || couriers.length === 0 ? (
        <div className="py-8 text-center">
          <p className="text-sm text-gray-500">Nenhum entregador disponivel no momento.</p>
        </div>
      ) : (
        <div className="space-y-4">
          <div className="max-h-64 space-y-2 overflow-y-auto">
            {couriers.map((courier) => (
              <button
                key={courier.id}
                type="button"
                onClick={() => setSelectedId(courier.id)}
                className={`w-full rounded-xl border p-3 text-left transition-colors ${
                  selectedId === courier.id
                    ? 'border-orange-300 bg-orange-50/60'
                    : 'border-gray-200/70 hover:border-gray-300'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{courier.name}</p>
                    <p className="text-xs text-gray-500">
                      {courier.phone}
                      {courier.vehicleType && ` · ${courier.vehicleType}`}
                    </p>
                  </div>
                  <CourierStatusBadge status={courier.status} />
                </div>
              </button>
            ))}
          </div>
          <div className="flex justify-end gap-3">
            <Button variant="secondary" onClick={handleClose} disabled={loading}>
              Cancelar
            </Button>
            <Button onClick={handleConfirm} loading={loading} disabled={!selectedId}>
              Atribuir
            </Button>
          </div>
        </div>
      )}
    </Modal>
  );
}
