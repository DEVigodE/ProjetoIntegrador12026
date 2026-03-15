import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Order } from '../types/order.types';

interface PageResponse<T> {
  content: T[];
}

export function useActiveOrders() {
  return useQuery<Order[]>({
    queryKey: ['orders', 'active'],
    queryFn: async () => {
      const { data } = await api.get<PageResponse<Order>>('/api/orders/active', {
        params: { size: 50 },
      });
      return data.content;
    },
    refetchInterval: 10_000,
  });
}
