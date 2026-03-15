import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Courier } from '../types/delivery.types';

export function useCouriers() {
  return useQuery<Courier[]>({
    queryKey: ['couriers'],
    queryFn: async () => {
      const { data } = await api.get<{ content: Courier[] }>('/api/couriers', {
        params: { size: 100 },
      });
      return data.content;
    },
  });
}
