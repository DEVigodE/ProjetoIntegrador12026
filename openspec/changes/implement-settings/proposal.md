## Why

A SettingsPage (`/settings`, somente ADMIN) e apenas um placeholder com titulo. O backoffice precisa de uma pagina de configuracoes onde o admin possa gerenciar categorias de produtos (listar e criar). O hook `useCategories` e o tipo `Category` ja existem no modulo catalog, podendo ser reutilizados.

## What Changes

- Criar hook `useCreateCategory` para POST /api/categories com invalidacao da query `['categories']`
- Criar componente `CategoryManager` com lista de categorias e formulario inline para criacao
- Implementar `SettingsPage` completa com PageHeader e CategoryManager
- Remover `.gitkeep` do diretorio settings (que passara a ter conteudo)

Nota: O backend NAO expoe endpoint PUT/PATCH para categorias, portanto a edicao de categorias nao sera implementada nesta change (apenas listagem e criacao).

## Capabilities

### New Capabilities

### Modified Capabilities
- `settings`: Implementacao da SettingsPage com CategoryManager (listar e criar categorias)

## Impact

- **Codigo afetado**: `features/settings/pages/SettingsPage.tsx` (substituir placeholder)
- **Novo diretorio**: `features/settings/components/`
- **Novo arquivo**: `features/settings/hooks/useCreateCategory.ts`
- **Reutiliza**: `useCategories` e `Category` type do modulo catalog
- **Backend**: Consome `GET /api/categories` e `POST /api/categories`
