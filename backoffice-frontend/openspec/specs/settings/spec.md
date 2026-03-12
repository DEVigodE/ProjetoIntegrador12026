# Settings

Pagina de configuracoes com gerenciamento de categorias (somente ADMIN).

## Requirements

### Requirement: Acesso restrito a ADMIN
O sistema SHALL restringir a pagina `/settings` exclusivamente a usuarios com role ADMIN.

#### Scenario: ADMIN acessa settings
- **WHEN** um usuario ADMIN navega para `/settings`
- **THEN** a SettingsPage e exibida

#### Scenario: Non-ADMIN bloqueado
- **WHEN** um usuario OPERATOR ou DISPATCHER tenta acessar `/settings`
- **THEN** o acesso e negado

### Requirement: CategoryManager - listar categorias
O sistema SHALL exibir uma lista de categorias existentes com nome e status (ativo/inativo).

#### Scenario: Categorias listadas
- **WHEN** a SettingsPage carrega
- **THEN** todas as categorias sao listadas via `GET /api/categories`

### Requirement: CategoryManager - criar categoria
O sistema SHALL permitir criar uma nova categoria com nome e descricao via `POST /api/categories`.

#### Scenario: Criar categoria
- **WHEN** o usuario preenche o nome da categoria e clica "Criar"
- **THEN** `POST /api/categories` e chamado e a lista e atualizada

#### Scenario: Validacao de nome obrigatorio
- **WHEN** o usuario tenta criar uma categoria sem nome
- **THEN** uma mensagem de erro e exibida

### Requirement: CategoryManager - editar nome da categoria
O sistema SHALL permitir editar o nome de uma categoria existente.

#### Scenario: Editar categoria
- **WHEN** o usuario clica em editar, altera o nome e salva
- **THEN** a categoria e atualizada e a lista reflete a mudanca
