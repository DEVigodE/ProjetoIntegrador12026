import { useState } from 'react';
import Modal from '../../../components/ui/Modal';
import Button from '../../../components/ui/Button';
import Input from '../../../components/ui/Input';

interface RejectOrderModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (reason: string) => void;
  loading: boolean;
}

export default function RejectOrderModal({
  isOpen,
  onClose,
  onConfirm,
  loading,
}: RejectOrderModalProps) {
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');

  function handleConfirm() {
    if (!reason.trim()) {
      setError('Motivo e obrigatorio');
      return;
    }
    onConfirm(reason.trim());
  }

  function handleClose() {
    setReason('');
    setError('');
    onClose();
  }

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Recusar Pedido">
      <div className="space-y-4">
        <Input
          label="Motivo da recusa"
          placeholder="Ex: Sem ingredientes, fora do horario..."
          value={reason}
          onChange={(e) => {
            setReason(e.target.value);
            if (error) setError('');
          }}
          error={error}
        />
        <div className="flex justify-end gap-3">
          <Button variant="secondary" onClick={handleClose} disabled={loading}>
            Cancelar
          </Button>
          <Button variant="danger" onClick={handleConfirm} loading={loading}>
            Recusar Pedido
          </Button>
        </div>
      </div>
    </Modal>
  );
}
