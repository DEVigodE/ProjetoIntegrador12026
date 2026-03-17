import { useQuery } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Product, ProductFilters, PageResponse } from '../types/product.types';

interface UseProductsParams {
  page?: number;
  size?: number;
  filters?: ProductFilters;
}

export function useProducts({ page = 0, size = 20, filters }: UseProductsParams = {}) {
  return useQuery<PageResponse<Product>>({
    queryKey: ['products', { page, size, ...filters }],
    queryFn: async () => {
      const { data } = await api.get<PageResponse<Product>>('/api/products', {
        params: {
          page,
          size,
          name: filters?.name || undefined,
          categoryId: filters?.categoryId || undefined,
          available: filters?.available !== undefined ? filters.available : undefined,
        },
      });
      return data;
    },
  });
}
