import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';

interface AssignCourierData {
  deliveryId: number;
  courierId: number;
}

export function useAssignCourier() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, AssignCourierData>({
    mutationFn: async ({ deliveryId, courierId }) => {
      await api.patch(`/api/deliveries/${deliveryId}/assign`, { courierId });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['deliveries'] });
      queryClient.invalidateQueries({ queryKey: ['couriers'] });
    },
  });
}
