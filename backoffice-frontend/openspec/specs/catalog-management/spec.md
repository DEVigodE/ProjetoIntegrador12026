# Catalog Management

Gerenciamento de produtos e categorias do catalogo.

## Requirements

### Requirement: Listagem de produtos paginada
O sistema SHALL exibir uma tabela paginada de produtos em `ProductListPage` com colunas: Nome, Categoria, Preco, Estoque, Status (ativo/inativo), Acoes. A listagem SHALL usar o hook `useProducts` que consome `GET /api/products?page=0&size=20`.

#### Scenario: Listar produtos
- **WHEN** o usuario acessa `/products`
- **THEN** uma tabela paginada de produtos e exibida com nome, categoria, preco, estoque e status

#### Scenario: Paginacao funciona
- **WHEN** o usuario clica na pagina 2
- **THEN** a query e refeita com `page=1` e os produtos da segunda pagina sao exibidos

### Requirement: Filtros de produtos
O sistema SHALL permitir filtrar produtos por nome, categoria e disponibilidade.

#### Scenario: Filtrar por nome
- **WHEN** o usuario digita "Pizza" no campo de busca
- **THEN** apenas produtos cujo nome contem "Pizza" sao exibidos

#### Scenario: Filtrar por categoria
- **WHEN** o usuario seleciona a categoria "Bebidas" no filtro
- **THEN** apenas produtos da categoria "Bebidas" sao exibidos

### Requirement: Toggle de disponibilidade
O sistema SHALL permitir alternar a disponibilidade de um produto inline na tabela via `PATCH /api/products/{id}/availability`.

#### Scenario: Desativar produto
- **WHEN** o usuario clica no toggle de disponibilidade de um produto ativo
- **THEN** o produto e marcado como indisponivel e o toggle atualiza visualmente

### Requirement: Alerta de estoque baixo
O sistema SHALL exibir um badge vermelho em produtos cujo `stockQuantity` esta abaixo de `minStockAlert`.

#### Scenario: Produto com estoque baixo
- **WHEN** um produto tem stockQuantity=3 e minStockAlert=5
- **THEN** um badge vermelho de alerta e exibido na coluna de estoque

### Requirement: Exclusao de produto (soft delete)
O sistema SHALL permitir excluir um produto (soft delete) via `DELETE /api/products/{id}` com um `ConfirmDialog` de confirmacao. Somente ADMIN pode excluir.

#### Scenario: ADMIN exclui produto
- **WHEN** um usuario ADMIN confirma a exclusao de um produto
- **THEN** o produto e removido da listagem (soft delete no backend)

### Requirement: Formulario de produto
O sistema SHALL ter um `ProductFormPage` para criacao e edicao de produtos com campos: nome, descricao, preco, categoria (select), URL imagem, estoque atual, estoque minimo. A validacao SHALL usar Zod via React Hook Form.

#### Scenario: Criar produto
- **WHEN** o usuario preenche o formulario e clica "Salvar"
- **THEN** `POST /api/products` e chamado e o usuario e redirecionado para `/products`

#### Scenario: Editar produto
- **WHEN** o usuario acessa `/products/:id/edit`
- **THEN** o formulario e preenchido com os dados atuais do produto (via `GET /api/products/{id}`)

#### Scenario: Validacao com Zod
- **WHEN** o usuario tenta salvar com nome vazio ou preco negativo
- **THEN** mensagens de erro sao exibidas nos campos invalidos

### Requirement: Listagem de categorias
O sistema SHALL consumir `GET /api/categories` para popular o select de categorias no formulario de produto.

#### Scenario: Categorias carregadas no select
- **WHEN** o formulario de produto e aberto
- **THEN** o select de categoria exibe todas as categorias ativas do backend

### Requirement: Hooks TanStack Query para catalogo
O sistema SHALL implementar os seguintes hooks:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useProducts` | GET | `/api/products?page=&size=&...` |
| `useProduct` | GET | `/api/products/{id}` |
| `useCreateProduct` | POST | `/api/products` |
| `useUpdateProduct` | PUT | `/api/products/{id}` |
| `useDeleteProduct` | DELETE | `/api/products/{id}` |
| `useToggleAvailability` | PATCH | `/api/products/{id}/availability` |
| `useCategories` | GET | `/api/categories` |
| `useCreateCategory` | POST | `/api/categories` |

#### Scenario: Mutation invalida queries relacionadas
- **WHEN** `useCreateProduct` executa com sucesso
- **THEN** a query `useProducts` e invalidada e os dados sao refetchados

### Requirement: Tipos TypeScript do catalogo
O sistema SHALL definir os tipos em `product.types.ts`:

```ts
interface Product {
  id: number; name: string; description?: string; price: number;
  imageUrl?: string; available: boolean; stockQuantity: number;
  minStockAlert: number; category: Category;
  deletedAt?: string; createdAt: string; updatedAt: string;
}
interface Category {
  id: number; name: string; description?: string; active: boolean;
}
```

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna um produto via GET /api/products/{id}
- **THEN** a resposta e corretamente tipada como `Product`
