export type CourierStatus = 'AVAILABLE' | 'BUSY' | 'OFFLINE';

export type DeliveryStatus = 'PENDING' | 'ASSIGNED' | 'PICKED_UP' | 'DELIVERED';

export interface Courier {
  id: number;
  name: string;
  phone: string;
  email?: string;
  vehicleType?: string;
  vehiclePlate?: string;
  status: CourierStatus;
  active: boolean;
}

export interface Delivery {
  id: number;
  orderId: number;
  courier?: Courier;
  status: DeliveryStatus;
  assignedAt?: string;
  pickedUpAt?: string;
  deliveredAt?: string;
  createdAt: string;
}
