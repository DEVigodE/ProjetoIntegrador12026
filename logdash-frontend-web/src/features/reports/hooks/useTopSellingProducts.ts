import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { TopProduct } from '../types/report.types';

export function useTopSellingProducts() {
  return useQuery<TopProduct[]>({
    queryKey: ['topSellingProducts'],
    queryFn: async () => {
      const { data } = await api.get<TopProduct[]>('/api/reports/products/top-selling', {
        params: { limit: 10 },
      });
      return data;
    },
  });
}
