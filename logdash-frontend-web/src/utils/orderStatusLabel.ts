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

const statusColors: Record<OrderStatus, 'green' | 'yellow' | 'blue' | 'red' | 'gray'> = {
  PENDING: 'yellow',
  ACCEPTED: 'blue',
  PREPARING: 'yellow',
  READY: 'green',
  OUT_FOR_DELIVERY: 'blue',
  DELIVERED: 'green',
  CANCELLED: 'red',
};

export function getStatusLabel(status: OrderStatus): string {
  return statusLabels[status];
}

export function getStatusColor(status: OrderStatus): 'green' | 'yellow' | 'blue' | 'red' | 'gray' {
  return statusColors[status];
}
