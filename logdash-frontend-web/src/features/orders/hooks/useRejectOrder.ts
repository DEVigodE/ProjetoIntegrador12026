import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';

interface RejectOrderData {
  id: number;
  reason: string;
}

export function useRejectOrder() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, RejectOrderData>({
    mutationFn: async ({ id, reason }) => {
      await api.patch(`/api/orders/${id}/reject`, { reason });
    },
    onSuccess: (_data, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.invalidateQueries({ queryKey: ['order', id] });
    },
  });
}
