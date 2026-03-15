import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Courier } from '../types/delivery.types';

interface UpdateCourierData {
  id: number;
  name: string;
  phone: string;
  email?: string;
  vehicleType?: string;
  vehiclePlate?: string;
  active: boolean;
}

export function useUpdateCourier() {
  const queryClient = useQueryClient();

  return useMutation<Courier, Error, UpdateCourierData>({
    mutationFn: async ({ id, ...data }) => {
      const { data: courier } = await api.put<Courier>(`/api/couriers/${id}`, data);
      return courier;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['couriers'] });
    },
  });
}
