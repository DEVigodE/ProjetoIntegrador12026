import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { OrderStatus } from '../types/order.types';

interface UpdateOrderStatusData {
  id: number;
  status: OrderStatus;
}

export function useUpdateOrderStatus() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, UpdateOrderStatusData>({
    mutationFn: async ({ id, status }) => {
      await api.patch(`/api/orders/${id}/status`, { status });
    },
    onSuccess: (_data, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.invalidateQueries({ queryKey: ['order', id] });
    },
  });
}
