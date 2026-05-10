import { useEffect } from 'react';
import { useForm, type Resolver } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import CategorySelect from './CategorySelect';
import type { Product } from '../types/product.types';

const productSchema = z.object({
  name: z.string().min(1, 'Nome e obrigatorio'),
  description: z.string().optional(),
  price: z.coerce.number().positive('Preco deve ser maior que zero'),
  categoryId: z.coerce.number().min(1, 'Selecione uma categoria'),
  imageUrl: z.string().url('URL invalida').optional().or(z.literal('')),
  stockQuantity: z.coerce.number().int().min(0, 'Estoque nao pode ser negativo'),
  minStockAlert: z.coerce.number().int().min(0, 'Estoque minimo nao pode ser negativo'),
});

export type ProductFormData = z.infer<typeof productSchema>;

interface ProductFormProps {
  product?: Product;
  onSubmit: (data: ProductFormData) => void;
  isSubmitting: boolean;
}

export default function ProductForm({ product, onSubmit, isSubmitting }: ProductFormProps) {
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ProductFormData, unknown, ProductFormData>({
    resolver: zodResolver(productSchema) as Resolver<ProductFormData>,
    defaultValues: {
      name: '',
      description: '',
      price: 0,
      categoryId: 0,
      imageUrl: '',
      stockQuantity: 0,
      minStockAlert: 0,
    },
  });

  useEffect(() => {
    if (product) {
      reset({
        name: product.name,
        description: product.description ?? '',
        price: product.price,
        categoryId: product.categoryId ?? 0,
        imageUrl: product.imageUrl ?? '',
        stockQuantity: product.stockQuantity,
        minStockAlert: product.minStockAlert,
      });
    }
  }, [product, reset]);

  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="max-w-2xl space-y-6 rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]"
    >
      <Input
        label="Nome"
        placeholder="Nome do produto"
        error={errors.name?.message}
        {...register('name')}
      />

      <Input
        label="Descricao"
        placeholder="Descricao do produto (opcional)"
        error={errors.description?.message}
        {...register('description')}
      />

      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Preco (R$)"
          type="number"
          step="0.01"
          min="0"
          placeholder="0,00"
          error={errors.price?.message}
          {...register('price')}
        />

        <CategorySelect
          label="Categoria"
          error={errors.categoryId?.message}
          {...register('categoryId')}
        />
      </div>

      <Input
        label="URL da Imagem"
        placeholder="https://exemplo.com/imagem.jpg (opcional)"
        error={errors.imageUrl?.message}
        {...register('imageUrl')}
      />

      <div className="grid grid-cols-2 gap-4">
        <Input
          label="Estoque Atual"
          type="number"
          min="0"
          placeholder="0"
          error={errors.stockQuantity?.message}
          {...register('stockQuantity')}
        />

        <Input
          label="Estoque Minimo (alerta)"
          type="number"
          min="0"
          placeholder="0"
          error={errors.minStockAlert?.message}
          {...register('minStockAlert')}
        />
      </div>

      <div className="flex gap-3">
        <Button type="submit" loading={isSubmitting}>
          Salvar
        </Button>
      </div>
    </form>
  );
}
