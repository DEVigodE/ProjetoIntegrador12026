import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';

export function useAcceptOrder() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, number>({
    mutationFn: async (id) => {
      await api.patch(`/api/orders/${id}/accept`);
    },
    onSuccess: (_data, id) => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.invalidateQueries({ queryKey: ['order', id] });
    },
  });
}
