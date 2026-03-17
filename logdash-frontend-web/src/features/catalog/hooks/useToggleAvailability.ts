import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Product, PageResponse } from '../types/product.types';

export function useToggleAvailability() {
  const queryClient = useQueryClient();

  return useMutation<void, Error, Product>({
    mutationFn: async (product) => {
      await api.patch(`/api/products/${product.id}/availability`);
    },
    onMutate: async (product) => {
      await queryClient.cancelQueries({ queryKey: ['products'] });

      const previousQueries = queryClient.getQueriesData<PageResponse<Product>>({
        queryKey: ['products'],
      });

      queryClient.setQueriesData<PageResponse<Product>>(
        { queryKey: ['products'] },
        (old) => {
          if (!old) return old;
          return {
            ...old,
            content: old.content.map((p) =>
              p.id === product.id ? { ...p, available: !p.available } : p
            ),
          };
        }
      );

      return { previousQueries };
    },
    onError: (_err, _product, context) => {
      const ctx = context as { previousQueries: [readonly unknown[], PageResponse<Product> | undefined][] } | undefined;
      ctx?.previousQueries.forEach(([queryKey, data]) => {
        queryClient.setQueryData(queryKey, data);
      });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
