## 1. Tipos e Infraestrutura

- [x] 1.1 Criar `features/catalog/types/product.types.ts` com interfaces `Product`, `Category` e tipos auxiliares (filtros, paginacao)

## 2. Hooks TanStack Query

- [x] 2.1 Criar `useProducts` — GET `/api/products` com filtros e paginacao como queryKey
- [x] 2.2 Criar `useProduct` — GET `/api/products/{id}` para formulario de edicao
- [x] 2.3 Criar `useCreateProduct` — POST `/api/products` com invalidacao de `['products']`
- [x] 2.4 Criar `useUpdateProduct` — PUT `/api/products/{id}` com invalidacao de `['products']` e `['product', id]`
- [x] 2.5 Criar `useDeleteProduct` — DELETE `/api/products/{id}` com invalidacao de `['products']`
- [x] 2.6 Criar `useToggleAvailability` — PATCH `/api/products/{id}/availability` com optimistic update
- [x] 2.7 Criar `useCategories` — GET `/api/categories` para popular selects

## 3. Componentes do Catalogo

- [x] 3.1 Criar `StockBadge` — badge vermelho/verde baseado em stockQuantity vs minStockAlert
- [x] 3.2 Criar `ProductFilters` — inputs de nome (com debounce 300ms), select de categoria e select de disponibilidade
- [x] 3.3 Criar `ProductTable` — tabela usando componente `Table` com colunas nome, categoria, preco, estoque (StockBadge), status (toggle), acoes (editar/excluir)
- [x] 3.4 Criar `CategorySelect` — select que consome `useCategories` com estado de loading
- [x] 3.5 Criar `ProductForm` — formulario com React Hook Form + Zod (nome, descricao, preco, categoria, imagem URL, estoque, estoque minimo)

## 4. Paginas

- [x] 4.1 Implementar `ProductListPage` — PageHeader, ProductFilters, ProductTable, Pagination, ConfirmDialog para delete, EmptyState
- [x] 4.2 Implementar `ProductFormPage` — PageHeader, ProductForm, logica de criacao vs edicao baseada em `useParams`, redirecionamento apos sucesso
