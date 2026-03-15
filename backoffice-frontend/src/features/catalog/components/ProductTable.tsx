import { useNavigate } from 'react-router-dom';
import { useKeycloak } from '@react-keycloak/web';
import Table, { type Column } from '../../../components/ui/Table';
import Badge from '../../../components/ui/Badge';
import Button from '../../../components/ui/Button';
import StockBadge from './StockBadge';
import type { Product } from '../types/product.types';

interface ProductTableProps {
  products: Product[];
  onToggleAvailability: (product: Product) => void;
  onDelete: (product: Product) => void;
}

export default function ProductTable({
  products,
  onToggleAvailability,
  onDelete,
}: ProductTableProps) {
  const navigate = useNavigate();
  const { keycloak } = useKeycloak();
  const userRoles: string[] = keycloak.tokenParsed?.realm_access?.roles ?? [];
  const isAdmin = userRoles.includes('ADMIN');

  const formatCurrency = (value: number) =>
    new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

  const columns: Column<Product>[] = [
    {
      key: 'name',
      header: 'Nome',
      sortable: true,
    },
    {
      key: 'category',
      header: 'Categoria',
      render: (product) => product.categoryName ?? '—',
    },
    {
      key: 'price',
      header: 'Preco',
      sortable: true,
      render: (product) => formatCurrency(product.price),
    },
    {
      key: 'stockQuantity',
      header: 'Estoque',
      sortable: true,
      render: (product) => (
        <StockBadge
          stockQuantity={product.stockQuantity}
          minStockAlert={product.minStockAlert}
        />
      ),
    },
    {
      key: 'available',
      header: 'Status',
      render: (product) => (
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation();
            onToggleAvailability(product);
          }}
          className="cursor-pointer"
          aria-label={product.available ? 'Desativar produto' : 'Ativar produto'}
        >
          <Badge variant={product.available ? 'green' : 'gray'}>
            {product.available ? 'Disponivel' : 'Indisponivel'}
          </Badge>
        </button>
      ),
    },
    {
      key: 'actions',
      header: 'Acoes',
      render: (product) => (
        <div className="flex gap-2">
          <Button
            size="sm"
            variant="secondary"
            onClick={(e) => {
              e.stopPropagation();
              navigate(`/products/${product.id}/edit`);
            }}
          >
            Editar
          </Button>
          {isAdmin && (
            <Button
              size="sm"
              variant="danger"
              onClick={(e) => {
                e.stopPropagation();
                onDelete(product);
              }}
            >
              Excluir
            </Button>
          )}
        </div>
      ),
    },
  ];

  return (
    <Table<Product>
      columns={columns}
      data={products}
      keyExtractor={(p) => p.id}
    />
  );
}
