import type { CourierStatus, DeliveryStatus } from '../features/delivery/types/delivery.types';

const courierStatusLabels: Record<CourierStatus, string> = {
  AVAILABLE: 'Disponivel',
  BUSY: 'Ocupado',
  OFFLINE: 'Offline',
};

const courierStatusColors: Record<CourierStatus, 'green' | 'yellow' | 'gray'> = {
  AVAILABLE: 'green',
  BUSY: 'yellow',
  OFFLINE: 'gray',
};

const deliveryStatusLabels: Record<DeliveryStatus, string> = {
  PENDING: 'Pendente',
  ASSIGNED: 'Atribuida',
  PICKED_UP: 'Retirada',
  DELIVERED: 'Entregue',
};

const deliveryStatusColors: Record<DeliveryStatus, 'green' | 'yellow' | 'blue' | 'gray'> = {
  PENDING: 'yellow',
  ASSIGNED: 'blue',
  PICKED_UP: 'blue',
  DELIVERED: 'green',
};

export function getCourierStatusLabel(status: CourierStatus): string {
  return courierStatusLabels[status];
}

export function getCourierStatusColor(status: CourierStatus): 'green' | 'yellow' | 'gray' {
  return courierStatusColors[status];
}

export function getDeliveryStatusLabel(status: DeliveryStatus): string {
  return deliveryStatusLabels[status];
}

export function getDeliveryStatusColor(status: DeliveryStatus): 'green' | 'yellow' | 'blue' | 'gray' {
  return deliveryStatusColors[status];
}
