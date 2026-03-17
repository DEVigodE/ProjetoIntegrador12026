import { useParams, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Spinner from '../../../components/ui/Spinner';
import ProductForm, { type ProductFormData } from '../components/ProductForm';
import { useProduct } from '../hooks/useProduct';
import { useCreateProduct } from '../hooks/useCreateProduct';
import { useUpdateProduct } from '../hooks/useUpdateProduct';

export default function ProductFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const productId = id ? Number(id) : undefined;
  const isEditing = !!productId;

  const { data: product, isLoading } = useProduct(productId);
  const createProduct = useCreateProduct();
  const updateProduct = useUpdateProduct(productId ?? 0);

  const title = isEditing ? 'Editar Produto' : 'Novo Produto';

  function handleSubmit(data: ProductFormData) {
    const payload = {
      ...data,
      imageUrl: data.imageUrl || undefined,
      description: data.description || undefined,
    };

    if (isEditing) {
      updateProduct.mutate(payload, {
        onSuccess: () => {
          toast.success('Produto atualizado com sucesso.');
          navigate('/products');
        },
        onError: () => toast.error('Erro ao atualizar produto.'),
      });
    } else {
      createProduct.mutate(payload, {
        onSuccess: () => {
          toast.success('Produto criado com sucesso.');
          navigate('/products');
        },
        onError: () => toast.error('Erro ao criar produto.'),
      });
    }
  }

  if (isEditing && isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner size="lg" />
      </div>
    );
  }

  return (
    <>
      <PageHeader
        title={title}
        breadcrumbs={[
          { label: 'Produtos', path: '/products' },
          { label: title },
        ]}
      />
      <ProductForm
        product={product}
        onSubmit={handleSubmit}
        isSubmitting={createProduct.isPending || updateProduct.isPending}
      />
    </>
  );
}
