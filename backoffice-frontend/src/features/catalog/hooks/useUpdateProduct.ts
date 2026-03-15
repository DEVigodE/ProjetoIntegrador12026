import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Product } from '../types/product.types';

interface UpdateProductData {
  name: string;
  description?: string;
  price: number;
  categoryId: number;
  imageUrl?: string;
  stockQuantity: number;
  minStockAlert: number;
}

export function useUpdateProduct(id: number) {
  const queryClient = useQueryClient();

  return useMutation<Product, Error, UpdateProductData>({
    mutationFn: async (data) => {
      const { data: product } = await api.put<Product>(`/api/products/${id}`, data);
      return product;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['product', id] });
    },
  });
}
