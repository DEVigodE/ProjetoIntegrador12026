import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Product } from '../types/product.types';

export function useProduct(id: number | undefined) {
  return useQuery<Product>({
    queryKey: ['product', id],
    queryFn: async () => {
      const { data } = await api.get<Product>(`/api/products/${id}`);
      return data;
    },
    enabled: !!id,
  });
}
