import Button from '../../../components/ui/Button';
import type { OrderStatus } from '../types/order.types';

interface OrderActionsProps {
  status: OrderStatus;
  onAccept: () => void;
  onReject: () => void;
  onUpdateStatus: (status: OrderStatus) => void;
  isLoading?: boolean;
}

export default function OrderActions({
  status,
  onAccept,
  onReject,
  onUpdateStatus,
  isLoading = false,
}: OrderActionsProps) {
  switch (status) {
    case 'PENDING':
      return (
        <div className="flex gap-3">
          <Button onClick={onAccept} loading={isLoading}>
            Aceitar
          </Button>
          <Button variant="danger" onClick={onReject} disabled={isLoading}>
            Recusar
          </Button>
        </div>
      );
    case 'ACCEPTED':
      return (
        <Button onClick={() => onUpdateStatus('PREPARING')} loading={isLoading}>
          Iniciar Preparo
        </Button>
      );
    case 'PREPARING':
      return (
        <Button onClick={() => onUpdateStatus('READY')} loading={isLoading}>
          Pronto para Retirada
        </Button>
      );
    case 'READY':
      return (
        <Button onClick={() => onUpdateStatus('OUT_FOR_DELIVERY')} loading={isLoading}>
          Saiu para Entrega
        </Button>
      );
    case 'OUT_FOR_DELIVERY':
      return (
        <Button onClick={() => onUpdateStatus('DELIVERED')} loading={isLoading}>
          Finalizar Entrega
        </Button>
      );
    default:
      return null;
  }
}
