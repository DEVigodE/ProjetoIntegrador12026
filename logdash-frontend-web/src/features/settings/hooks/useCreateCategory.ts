import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../../config/axios';
import type { Category } from '../../catalog/types/product.types';

interface CreateCategoryData {
  name: string;
  description?: string;
}

export function useCreateCategory() {
  const queryClient = useQueryClient();

  return useMutation<Category, Error, CreateCategoryData>({
    mutationFn: async (data) => {
      const { data: category } = await api.post<Category>('/api/categories', data);
      return category;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
    },
  });
}
