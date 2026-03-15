import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Delivery } from '../types/delivery.types';

export function useDeliveries() {
  return useQuery<Delivery[]>({
    queryKey: ['deliveries'],
    queryFn: async () => {
      const { data } = await api.get<{ content: Delivery[] }>('/api/deliveries/active');
      return data.content;
    },
  });
}
