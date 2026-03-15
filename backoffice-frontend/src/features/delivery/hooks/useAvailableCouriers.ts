import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Courier } from '../types/delivery.types';

export function useAvailableCouriers(enabled = true) {
  return useQuery<Courier[]>({
    queryKey: ['couriers', 'available'],
    queryFn: async () => {
      const { data } = await api.get<Courier[]>('/api/couriers/available');
      return data;
    },
    enabled,
  });
}
