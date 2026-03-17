import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Order, OrderStatus } from '../types/order.types';

interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
}

interface UseOrdersParams {
  page?: number;
  size?: number;
  status?: OrderStatus;
}

export function useOrders({ page = 0, size = 20, status }: UseOrdersParams = {}) {
  return useQuery<PageResponse<Order>>({
    queryKey: ['orders', { page, size, status }],
    queryFn: async () => {
      const { data } = await api.get<PageResponse<Order>>('/api/orders', {
        params: {
          page,
          size,
          status: status || undefined,
        },
      });
      return data;
    },
  });
}
