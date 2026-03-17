import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Category } from '../types/product.types';

export function useCategories() {
  return useQuery<Category[]>({
    queryKey: ['categories'],
    queryFn: async () => {
      const { data } = await api.get<Category[]>('/api/categories');
      return data;
    },
  });
}
