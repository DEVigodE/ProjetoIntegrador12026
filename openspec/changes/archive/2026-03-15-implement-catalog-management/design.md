## Context

O backoffice frontend ja possui layout (MainLayout, Sidebar, Header), roteamento com guards (PrivateRoute, RoleGuard), componentes UI reutilizaveis (Button, Input, Select, Table, Pagination, Modal, ConfirmDialog, Badge, EmptyState, Spinner) e o dashboard implementado. As rotas `/products`, `/products/new` e `/products/:id/edit` ja estao definidas no App.tsx mas apontam para stubs.

O backend Spring Boot expoe endpoints REST completos para produtos (`/api/products`) e categorias (`/api/categories`) com paginacao, filtros e soft delete. A autenticacao JWT via Keycloak ja esta configurada no interceptor Axios.

## Goals / Non-Goals

**Goals:**
- Implementar CRUD completo de produtos com listagem paginada, filtros e formulario com validacao
- Permitir toggle de disponibilidade inline na tabela
- Exibir alerta visual de estoque baixo
- Permitir soft delete de produtos (somente ADMIN)
- Consumir endpoints de categorias para popular selects

**Non-Goals:**
- CRUD completo de categorias (sera feito na spec `settings`)
- Upload de imagem de produto (usa URL externa)
- Drag-and-drop para reordenar produtos
- Busca full-text no backend (filtro por nome usa query param simples)

## Decisions

### 1. Hooks seguem padrao existente (useQuery/useMutation do TanStack Query)

Cada operacao tem seu proprio hook em arquivo separado, seguindo o padrao ja estabelecido em `features/orders/hooks/`. Queries usam `useQuery` com queryKey semantico (`['products', filters]`), mutations usam `useMutation` com `onSuccess` invalidando queries relacionadas.

**Alternativa descartada**: Hook unico com todas as operacoes — violaria o padrao existente e dificultaria tree-shaking.

### 2. Filtros como query params no useProducts

O hook `useProducts` recebe um objeto de filtros (name, categoryId, available) e paginacao (page, size) que sao passados como query params. O TanStack Query usa esses parametros como parte da queryKey para cache granular.

**Alternativa descartada**: Estado global de filtros com Zustand — overengineering para filtros locais de uma unica pagina.

### 3. Formulario com React Hook Form + Zod

O `ProductForm` usa `useForm` com `zodResolver` para validacao declarativa. O schema Zod define campos obrigatorios, tipos e constraints (preco > 0, nome nao vazio). Mesmo componente para criacao e edicao, diferenciado pelo prop `productId`.

### 4. Toggle de disponibilidade com optimistic update

O `useToggleAvailability` usa optimistic update no TanStack Query: atualiza o cache local imediatamente e reverte em caso de erro. Isso da feedback instantaneo ao usuario.

**Alternativa descartada**: Aguardar resposta do servidor — toggle ficaria lento e a UX sofreria.

### 5. Soft delete com ConfirmDialog

A exclusao usa o componente `ConfirmDialog` ja existente. Somente usuarios com role ADMIN veem o botao de excluir (checagem via `useHasRole`).

## Risks / Trade-offs

- **[Paginacao backend vs frontend]** → Usamos paginacao server-side (backend retorna `Page<Product>`). Trade-off: mais requests, mas escala melhor com muitos produtos.
- **[Optimistic update no toggle]** → Se o PATCH falhar, o UI reverte. Risco de flash visual momentaneo. Mitigacao: toast de erro informando a falha.
- **[Filtros sem debounce]** → Filtro por nome dispara request a cada mudanca. Mitigacao: adicionar debounce de 300ms no input de busca.
