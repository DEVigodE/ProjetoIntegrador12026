import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';

export function useDeleteProduct() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, number>({
    mutationFn: async (id) => {
      await api.delete(`/api/products/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
