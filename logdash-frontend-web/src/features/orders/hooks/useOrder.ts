import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Order } from '../types/order.types';

export function useOrder(id: number | undefined) {
  return useQuery<Order>({
    queryKey: ['order', id],
    queryFn: async () => {
      const { data } = await api.get<Order>(`/api/orders/${id}`);
      return data;
    },
    enabled: !!id,
  });
}
