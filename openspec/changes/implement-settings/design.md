## Context

A SettingsPage e um placeholder. O tipo `Category` e o hook `useCategories` ja existem em `features/catalog/`. O backend expoe `GET /api/categories` (lista) e `POST /api/categories` (criar com `{ name, description }`). Nao ha endpoint de edicao de categorias.

## Goals / Non-Goals

**Goals:**
- Implementar CategoryManager com lista de categorias e criacao inline
- Reutilizar `useCategories` e `Category` do modulo catalog
- Validar nome obrigatorio com Zod + React Hook Form

**Non-Goals:**
- Edicao de categorias (backend nao expoe PUT/PATCH)
- Outras configuracoes alem de categorias
- Exclusao de categorias

## Decisions

### 1. Reutilizar hooks e tipos do catalog
O `useCategories` e `Category` ja existem em `features/catalog/`. O hook `useCreateCategory` sera criado em `features/settings/hooks/` pois e uma acao administrativa, nao de catalogo. Ele invalida a query `['categories']` compartilhada.

### 2. Formulario inline no CategoryManager
O formulario de criacao sera inline (nao modal) com dois campos: nome (obrigatorio) e descricao (opcional). Validacao com Zod via React Hook Form, consistente com outros forms do projeto.

### 3. Lista simples com cards
Categorias exibidas como lista de cards com nome, descricao e badge ativo/inativo. Sem tabela pois o volume de categorias e pequeno.

## Risks / Trade-offs

- **[Sem edicao]** A spec original menciona edicao mas o backend nao tem o endpoint. → Implementar apenas o que a API suporta. A edicao pode ser adicionada quando o backend expor PUT /api/categories/{id}.
