# Settings (delta)

## MODIFIED Requirements

### Requirement: Hook useCreateCategory
O sistema SHALL implementar `useCreateCategory` em `features/settings/hooks/useCreateCategory.ts` usando TanStack Query mutation para `POST /api/categories` com payload `{ name, description }`. Ao sucesso, SHALL invalidar a query `['categories']`.

#### Scenario: Criar categoria com sucesso
- **WHEN** `useCreateCategory` executa com `{ name: "Bebidas", description: "Bebidas em geral" }`
- **THEN** POST /api/categories e chamado e a query `['categories']` e invalidada

### Requirement: CategoryManager com lista e criacao
O sistema SHALL implementar `CategoryManager` em `features/settings/components/CategoryManager.tsx` que:
1. Lista categorias existentes via `useCategories` (reutilizado de catalog) como cards com nome, descricao e badge ativo/inativo
2. Exibe formulario inline com campos nome (obrigatorio) e descricao (opcional)
3. Valida com Zod via React Hook Form (nome obrigatorio)
4. Ao submeter, chama `useCreateCategory` com toast de sucesso/erro
5. Exibe Spinner durante carregamento e EmptyState se nao ha categorias

#### Scenario: Categorias listadas
- **WHEN** a SettingsPage carrega
- **THEN** todas as categorias sao listadas com nome, descricao e badge de status

#### Scenario: Criar categoria
- **WHEN** o usuario preenche o nome e clica "Criar"
- **THEN** POST /api/categories e chamado e a lista atualiza com toast de sucesso

#### Scenario: Validacao de nome obrigatorio
- **WHEN** o usuario tenta criar sem nome
- **THEN** mensagem de erro e exibida no campo

#### Scenario: Estado vazio
- **WHEN** nao existem categorias
- **THEN** EmptyState e exibido com mensagem informativa

### Requirement: SettingsPage completa
O sistema SHALL implementar `SettingsPage` com PageHeader e CategoryManager. Somente ADMIN tem acesso (rota ja protegida por RoleGuard).

#### Scenario: Pagina completa
- **WHEN** o usuario ADMIN acessa `/settings`
- **THEN** a pagina exibe header e CategoryManager

#### Scenario: Acesso restrito a ADMIN
- **WHEN** um usuario OPERATOR tenta acessar `/settings`
- **THEN** o acesso e negado pelo RoleGuard
