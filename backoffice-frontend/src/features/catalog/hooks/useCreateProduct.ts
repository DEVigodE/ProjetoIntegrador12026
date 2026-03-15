import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Product } from '../types/product.types';

interface CreateProductData {
  name: string;
  description?: string;
  price: number;
  categoryId: number;
  imageUrl?: string;
  stockQuantity: number;
  minStockAlert: number;
}

export function useCreateProduct() {
  const queryClient = useQueryClient();

  return useMutation<Product, Error, CreateProductData>({
    mutationFn: async (data) => {
      const { data: product } = await api.post<Product>('/api/products', data);
      return product;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
}
