# Catalog Management

Gerenciamento de produtos e categorias do catalogo.

## Requirements

### Requirement: Tipos TypeScript do catalogo
O sistema SHALL definir os tipos `Product` e `Category` em `features/catalog/types/product.types.ts` espelhando os DTOs do backend. `Product` SHALL conter: id, name, description, price, imageUrl, available, stockQuantity, minStockAlert, category (Category), deletedAt, createdAt, updatedAt. `Category` SHALL conter: id, name, description, active.

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna um produto via `GET /api/products/{id}`
- **THEN** a resposta e corretamente tipada como `Product`

### Requirement: Hooks TanStack Query para catalogo
O sistema SHALL implementar os seguintes hooks em arquivos separados dentro de `features/catalog/hooks/`:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useProducts` | GET | `/api/products?page=&size=&name=&categoryId=&available=` |
| `useProduct` | GET | `/api/products/{id}` |
| `useCreateProduct` | POST | `/api/products` |
| `useUpdateProduct` | PUT | `/api/products/{id}` |
| `useDeleteProduct` | DELETE | `/api/products/{id}` |
| `useToggleAvailability` | PATCH | `/api/products/{id}/availability` |
| `useCategories` | GET | `/api/categories` |

#### Scenario: useProducts retorna lista paginada
- **WHEN** `useProducts` e chamado com `{ page: 0, size: 20 }`
- **THEN** o hook retorna `data` com a lista de produtos e metadados de paginacao

#### Scenario: Mutation invalida queries relacionadas
- **WHEN** `useCreateProduct` executa com sucesso
- **THEN** a query `['products']` e invalidada e os dados sao refetchados

#### Scenario: useToggleAvailability com optimistic update
- **WHEN** o toggle de disponibilidade e acionado
- **THEN** o cache local e atualizado imediatamente e revertido em caso de erro

### Requirement: Listagem de produtos paginada
O sistema SHALL exibir uma tabela paginada de produtos em `ProductListPage` com colunas: Nome, Categoria, Preco, Estoque, Status (ativo/inativo), Acoes. A listagem SHALL usar o componente `Table` existente e o hook `useProducts` com paginacao server-side.

#### Scenario: Listar produtos
- **WHEN** o usuario acessa `/products`
- **THEN** uma tabela paginada de produtos e exibida com nome, categoria, preco, estoque e status

#### Scenario: Paginacao funciona
- **WHEN** o usuario clica na pagina 2
- **THEN** a query e refeita com `page=1` e os produtos da segunda pagina sao exibidos

#### Scenario: Estado vazio
- **WHEN** nao existem produtos cadastrados
- **THEN** o componente `EmptyState` e exibido com mensagem e botao para criar produto

### Requirement: Filtros de produtos
O sistema SHALL permitir filtrar produtos por nome (com debounce de 300ms), categoria (select) e disponibilidade (select). Os filtros SHALL ser implementados no componente `ProductFilters` e passados como query params ao `useProducts`.

#### Scenario: Filtrar por nome
- **WHEN** o usuario digita "Pizza" no campo de busca
- **THEN** apos 300ms de debounce, apenas produtos cujo nome contem "Pizza" sao exibidos

#### Scenario: Filtrar por categoria
- **WHEN** o usuario seleciona a categoria "Bebidas" no filtro
- **THEN** apenas produtos da categoria "Bebidas" sao exibidos

#### Scenario: Limpar filtros
- **WHEN** o usuario clica em "Limpar filtros"
- **THEN** todos os filtros sao resetados e a listagem completa e exibida

### Requirement: Toggle de disponibilidade
O sistema SHALL permitir alternar a disponibilidade de um produto inline na tabela via `PATCH /api/products/{id}/availability` usando o hook `useToggleAvailability` com optimistic update.

#### Scenario: Desativar produto
- **WHEN** o usuario clica no toggle de disponibilidade de um produto ativo
- **THEN** o produto e marcado como indisponivel e o toggle atualiza visualmente de imediato

#### Scenario: Falha no toggle
- **WHEN** o PATCH falha
- **THEN** o toggle reverte ao estado anterior e um toast de erro e exibido

### Requirement: Alerta de estoque baixo
O sistema SHALL exibir um `StockBadge` vermelho em produtos cujo `stockQuantity` esta abaixo de `minStockAlert`. Produtos com estoque normal SHALL exibir badge verde.

#### Scenario: Produto com estoque baixo
- **WHEN** um produto tem stockQuantity=3 e minStockAlert=5
- **THEN** um badge vermelho de alerta e exibido na coluna de estoque

#### Scenario: Produto com estoque normal
- **WHEN** um produto tem stockQuantity=10 e minStockAlert=5
- **THEN** um badge verde e exibido na coluna de estoque

### Requirement: Exclusao de produto (soft delete)
O sistema SHALL permitir excluir um produto via `DELETE /api/products/{id}` com o componente `ConfirmDialog` de confirmacao. Somente usuarios com role ADMIN SHALL ver o botao de excluir (verificacao via `useHasRole('ADMIN')`).

#### Scenario: ADMIN exclui produto
- **WHEN** um usuario ADMIN confirma a exclusao de um produto
- **THEN** o produto e removido da listagem e um toast de sucesso e exibido

#### Scenario: OPERATOR nao ve botao de excluir
- **WHEN** um usuario OPERATOR acessa a listagem de produtos
- **THEN** o botao de excluir NAO e exibido nas acoes

### Requirement: Formulario de produto
O sistema SHALL ter um `ProductFormPage` para criacao e edicao de produtos com campos: nome (obrigatorio), descricao, preco (obrigatorio, > 0), categoria (select obrigatorio, via `useCategories`), URL imagem, estoque atual (obrigatorio, >= 0), estoque minimo (obrigatorio, >= 0). A validacao SHALL usar schema Zod via React Hook Form com `zodResolver`.

#### Scenario: Criar produto
- **WHEN** o usuario preenche o formulario e clica "Salvar"
- **THEN** `POST /api/products` e chamado e o usuario e redirecionado para `/products` com toast de sucesso

#### Scenario: Editar produto
- **WHEN** o usuario acessa `/products/:id/edit`
- **THEN** o formulario e preenchido com os dados atuais do produto via `useProduct(id)`

#### Scenario: Validacao com Zod
- **WHEN** o usuario tenta salvar com nome vazio ou preco negativo
- **THEN** mensagens de erro sao exibidas nos campos invalidos sem chamar a API

#### Scenario: Loading ao salvar
- **WHEN** a mutation esta em andamento
- **THEN** o botao "Salvar" exibe spinner e fica desabilitado

### Requirement: Select de categorias
O sistema SHALL implementar um componente `CategorySelect` que consome `useCategories` para popular o select de categorias no formulario de produto. Somente categorias ativas SHALL ser exibidas.

#### Scenario: Categorias carregadas no select
- **WHEN** o formulario de produto e aberto
- **THEN** o select de categoria exibe todas as categorias ativas do backend

#### Scenario: Loading de categorias
- **WHEN** as categorias estao sendo carregadas
- **THEN** o select exibe estado de loading
