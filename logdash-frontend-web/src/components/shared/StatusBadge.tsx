import Badge from '../ui/Badge';

type StatusType =
  | 'PENDING'
  | 'ACCEPTED'
  | 'PREPARING'
  | 'READY'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'CANCELLED'
  | 'ASSIGNED'
  | 'PICKED_UP'
  | 'AVAILABLE'
  | 'BUSY'
  | 'OFFLINE';

interface StatusConfig {
  label: string;
  variant: 'green' | 'yellow' | 'blue' | 'orange' | 'teal' | 'red' | 'gray';
}

const statusMap: Record<StatusType, StatusConfig> = {
  PENDING: { label: 'Pendente', variant: 'yellow' },
  ACCEPTED: { label: 'Aceito', variant: 'blue' },
  PREPARING: { label: 'Em Preparo', variant: 'orange' },
  READY: { label: 'Pronto', variant: 'green' },
  OUT_FOR_DELIVERY: { label: 'Saiu para Entrega', variant: 'teal' },
  DELIVERED: { label: 'Entregue', variant: 'green' },
  CANCELLED: { label: 'Cancelado', variant: 'red' },
  ASSIGNED: { label: 'Atribuido', variant: 'blue' },
  PICKED_UP: { label: 'Retirado', variant: 'blue' },
  AVAILABLE: { label: 'Disponivel', variant: 'green' },
  BUSY: { label: 'Ocupado', variant: 'yellow' },
  OFFLINE: { label: 'Offline', variant: 'gray' },
};

interface StatusBadgeProps {
  status: StatusType;
}

export default function StatusBadge({ status }: StatusBadgeProps) {
  const config = statusMap[status] ?? { label: status, variant: 'gray' as const };

  return <Badge variant={config.variant}>{config.label}</Badge>;
}
