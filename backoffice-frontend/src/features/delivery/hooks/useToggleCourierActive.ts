import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';

interface ToggleCourierActiveData {
  id: number;
  active: boolean;
}

export function useToggleCourierActive() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, ToggleCourierActiveData>({
    mutationFn: async ({ id, active }) => {
      const action = active ? 'activate' : 'deactivate';
      await api.patch(`/api/couriers/${id}/${action}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['couriers'] });
    },
  });
}
