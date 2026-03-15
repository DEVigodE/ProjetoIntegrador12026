import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Courier } from '../types/delivery.types';

interface CreateCourierData {
  name: string;
  phone: string;
  email?: string;
  vehicleType?: string;
  vehiclePlate?: string;
}

export function useCreateCourier() {
  const queryClient = useQueryClient();

  return useMutation<Courier, Error, CreateCourierData>({
    mutationFn: async (data) => {
      const { data: courier } = await api.post<Courier>('/api/couriers', data);
      return courier;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['couriers'] });
    },
  });
}
