import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import PageHeader from '../../../components/layout/PageHeader';
import Button from '../../../components/ui/Button';
import Spinner from '../../../components/ui/Spinner';
import EmptyState from '../../../components/ui/EmptyState';
import Pagination from '../../../components/ui/Pagination';
import ConfirmDialog from '../../../components/ui/ConfirmDialog';
import ProductTable from '../components/ProductTable';
import ProductFilters from '../components/ProductFilters';
import { useProducts } from '../hooks/useProducts';
import { useToggleAvailability } from '../hooks/useToggleAvailability';
import { useDeleteProduct } from '../hooks/useDeleteProduct';
import type { Product, ProductFilters as ProductFiltersType } from '../types/product.types';

export default function ProductListPage() {
  const navigate = useNavigate();
  const [page, setPage] = useState(0);
  const [filters, setFilters] = useState<ProductFiltersType>({});
  const [productToDelete, setProductToDelete] = useState<Product | null>(null);

  const { data, isLoading, isError } = useProducts({ page, size: 20, filters });
  const toggleAvailability = useToggleAvailability();
  const deleteProduct = useDeleteProduct();

  function handleFiltersChange(newFilters: ProductFiltersType) {
    setFilters(newFilters);
    setPage(0);
  }

  function handleToggleAvailability(product: Product) {
    toggleAvailability.mutate(product, {
      onError: () => toast.error('Erro ao alterar disponibilidade do produto.'),
    });
  }

  function handleConfirmDelete() {
    if (!productToDelete) return;
    deleteProduct.mutate(productToDelete.id, {
      onSuccess: () => {
        toast.success('Produto excluido com sucesso.');
        setProductToDelete(null);
      },
      onError: () => toast.error('Erro ao excluir produto.'),
    });
  }

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner size="lg" />
      </div>
    );
  }

  if (isError) {
    return (
      <EmptyState
        title="Erro ao carregar produtos"
        description="Tente novamente mais tarde."
      />
    );
  }

  const products = data?.content ?? [];
  const totalPages = data?.totalPages ?? 0;

  return (
    <>
      <div className="flex items-center justify-between">
        <PageHeader title="Produtos" />
        <Button onClick={() => navigate('/products/new')}>Novo Produto</Button>
      </div>

      <div className="mb-6">
        <ProductFilters filters={filters} onFiltersChange={handleFiltersChange} />
      </div>

      {products.length === 0 ? (
        <EmptyState
          title="Nenhum produto encontrado"
          description="Cadastre seu primeiro produto clicando no botao acima."
        />
      ) : (
        <>
          <ProductTable
            products={products}
            onToggleAvailability={handleToggleAvailability}
            onDelete={setProductToDelete}
          />
          <div className="mt-4">
            <Pagination
              currentPage={page + 1}
              totalPages={totalPages}
              onPageChange={(p) => setPage(p - 1)}
            />
          </div>
        </>
      )}

      <ConfirmDialog
        isOpen={!!productToDelete}
        onClose={() => setProductToDelete(null)}
        onConfirm={handleConfirmDelete}
        title="Excluir produto"
        message={`Tem certeza que deseja excluir "${productToDelete?.name}"? Esta acao nao pode ser desfeita.`}
        confirmLabel="Excluir"
        loading={deleteProduct.isPending}
      />
    </>
  );
}
