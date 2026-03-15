## Why

O backoffice ainda nao possui telas de gerenciamento de catalogo (produtos e categorias). Sem isso, a equipe do restaurante nao consegue cadastrar, editar, controlar disponibilidade ou monitorar estoque dos produtos — funcionalidades essenciais para operar o sistema de delivery.

## What Changes

- Criar `ProductListPage` com tabela paginada, filtros por nome/categoria/disponibilidade, toggle de disponibilidade inline e soft delete (ADMIN)
- Criar `ProductFormPage` para criacao e edicao de produtos com validacao Zod via React Hook Form
- Implementar badge de alerta de estoque baixo na listagem
- Criar hooks TanStack Query para todas as operacoes de catalogo (CRUD produtos, toggle disponibilidade, categorias)
- Definir tipos TypeScript (`Product`, `Category`) espelhando os DTOs do backend
- Criar componentes reutilizaveis: `ProductTable`, `ProductFilters`, `ProductForm`, `CategorySelect`, `StockBadge`

## Capabilities

### New Capabilities
- `catalog`: Gerenciamento completo de produtos e categorias — listagem paginada, filtros, CRUD, toggle de disponibilidade, alerta de estoque baixo

### Modified Capabilities

## Impact

- **Codigo**: Novos arquivos em `src/features/catalog/` (pages, components, hooks, types)
- **Rotas**: Ativacao das rotas `/products`, `/products/new`, `/products/:id/edit` ja definidas no `App.tsx`
- **APIs consumidas**: `GET/POST/PUT/DELETE /api/products`, `PATCH /api/products/{id}/availability`, `GET/POST /api/categories`
- **Dependencias**: Nenhuma nova — usa React Hook Form, Zod, TanStack Query e componentes UI ja instalados
