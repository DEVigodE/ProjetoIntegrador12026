import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { toast } from 'react-toastify';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import Badge from '../../../components/ui/Badge';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import { useCategories } from '../../catalog/hooks/useCategories';
import { useCreateCategory } from '../hooks/useCreateCategory';

const schema = z.object({
  name: z.string().min(1, 'Nome e obrigatorio'),
  description: z.string().optional(),
});

type CategoryFormData = z.infer<typeof schema>;

export default function CategoryManager() {
  const { data: categories, isLoading } = useCategories();
  const createCategory = useCreateCategory();

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<CategoryFormData>({
    resolver: zodResolver(schema),
  });

  function onSubmit(data: CategoryFormData) {
    createCategory.mutate(
      { name: data.name, description: data.description || undefined },
      {
        onSuccess: () => {
          toast.success('Categoria criada com sucesso.');
          reset();
        },
        onError: () => toast.error('Erro ao criar categoria.'),
      }
    );
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Formulario de criacao */}
      <div className="rounded-lg bg-white p-6 shadow-sm border border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Nova Categoria</h3>
        <form onSubmit={handleSubmit(onSubmit)} className="flex items-start gap-4">
          <div className="flex-1">
            <Input
              label="Nome"
              {...register('name')}
              error={errors.name?.message}
              placeholder="Ex: Bebidas"
            />
          </div>
          <div className="flex-1">
            <Input
              label="Descricao"
              {...register('description')}
              placeholder="Opcional"
            />
          </div>
          <div className="pt-6">
            <Button type="submit" loading={createCategory.isPending}>
              Criar
            </Button>
          </div>
        </form>
      </div>

      {/* Lista de categorias */}
      <div className="rounded-lg bg-white p-6 shadow-sm border border-gray-200">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Categorias</h3>
        {!categories || categories.length === 0 ? (
          <EmptyState
            title="Nenhuma categoria cadastrada"
            description="Crie sua primeira categoria usando o formulario acima."
          />
        ) : (
          <div className="space-y-3">
            {categories.map((cat) => (
              <div
                key={cat.id}
                className="flex items-center justify-between rounded-lg border border-gray-100 p-4"
              >
                <div>
                  <p className="text-sm font-medium text-gray-900">{cat.name}</p>
                  {cat.description && (
                    <p className="text-xs text-gray-500 mt-0.5">{cat.description}</p>
                  )}
                </div>
                <Badge variant={cat.active ? 'green' : 'gray'}>
                  {cat.active ? 'Ativo' : 'Inativo'}
                </Badge>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
