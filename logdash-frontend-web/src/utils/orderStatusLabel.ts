import type { OrderStatus } from '../features/orders/types/order.types';

const statusLabels: Record<OrderStatus, string> = {
  PENDING: 'Pendente',
  ACCEPTED: 'Aceito',
  PREPARING: 'Em Preparo',
  READY: 'Pronto',
  OUT_FOR_DELIVERY: 'Saiu para Entrega',
  DELIVERED: 'Entregue',
  CANCELLED: 'Cancelado',
};

const statusColors: Record<OrderStatus, 'green' | 'yellow' | 'blue' | 'orange' | 'teal' | 'red' | 'gray'> = {
  PENDING: 'yellow',
  ACCEPTED: 'blue',
  PREPARING: 'orange',
  READY: 'green',
  OUT_FOR_DELIVERY: 'teal',
  DELIVERED: 'green',
  CANCELLED: 'red',
};

export function getStatusLabel(status: OrderStatus): string {
  return statusLabels[status];
}

export function getStatusColor(
  status: OrderStatus
): 'green' | 'yellow' | 'blue' | 'orange' | 'teal' | 'red' | 'gray' {
  return statusColors[status];
}
