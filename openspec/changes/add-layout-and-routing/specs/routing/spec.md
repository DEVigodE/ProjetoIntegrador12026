## MODIFIED Requirements

### Requirement: PrivateRoute guard
O sistema SHALL ter um componente `PrivateRoute` que verifica `keycloak.authenticated` via hook `useKeycloak`. Se o usuario nao estiver autenticado, SHALL chamar `keycloak.login()` para redirecionar ao Keycloak. Se autenticado, SHALL renderizar o conteudo filho.

#### Scenario: Usuario nao autenticado
- **WHEN** um usuario nao autenticado acessa qualquer rota
- **THEN** `keycloak.login()` e chamado e ele e redirecionado para o Keycloak login

#### Scenario: Usuario autenticado
- **WHEN** um usuario autenticado acessa uma rota protegida
- **THEN** o conteudo da rota e renderizado

### Requirement: RoleGuard com mensagem de acesso negado
O sistema SHALL ter um componente `RoleGuard` que lê as roles do JWT via `keycloak.tokenParsed?.realm_access?.roles`. Se o usuario possuir pelo menos uma das roles exigidas, SHALL renderizar o conteudo filho. Caso contrario, SHALL exibir uma mensagem de "Acesso negado" (nao redirecionar).

#### Scenario: Usuario com role permitida
- **WHEN** um usuario OPERATOR acessa `/products`
- **THEN** a ProductListPage e renderizada

#### Scenario: Usuario sem role permitida
- **WHEN** um usuario DISPATCHER acessa `/reports`
- **THEN** uma mensagem de "Acesso negado" e exibida

#### Scenario: ADMIN acessa qualquer rota
- **WHEN** um usuario ADMIN acessa qualquer rota protegida por role
- **THEN** o conteudo e renderizado (ADMIN tem acesso a todas as rotas)

### Requirement: Rota raiz redireciona por role
O sistema SHALL redirecionar a rota `/` para a primeira rota acessivel do usuario: `/dashboard` para ADMIN e OPERATOR, `/deliveries` para DISPATCHER.

#### Scenario: ADMIN acessa raiz
- **WHEN** um usuario ADMIN acessa `/`
- **THEN** ele e redirecionado para `/dashboard`

#### Scenario: DISPATCHER acessa raiz
- **WHEN** um usuario DISPATCHER acessa `/`
- **THEN** ele e redirecionado para `/deliveries`

### Requirement: Mapa completo de rotas
O sistema SHALL implementar as seguintes rotas com suas respectivas paginas e roles, todas dentro do `MainLayout` como layout route:

| Rota | Pagina | Roles |
|---|---|---|
| `/dashboard` | DashboardPage | ADMIN, OPERATOR |
| `/products` | ProductListPage | ADMIN, OPERATOR |
| `/products/new` | ProductFormPage | ADMIN, OPERATOR |
| `/products/:id/edit` | ProductFormPage | ADMIN, OPERATOR |
| `/orders` | OrdersPage | ADMIN, OPERATOR |
| `/orders/:id` | OrderDetailPage | ADMIN, OPERATOR |
| `/couriers` | CouriersPage | ADMIN, DISPATCHER |
| `/deliveries` | DeliveriesPage | ADMIN, DISPATCHER |
| `/reports` | ReportsPage | ADMIN |
| `/settings` | SettingsPage | ADMIN |

#### Scenario: OPERATOR acessa rota de produtos
- **WHEN** um usuario OPERATOR navega para `/products`
- **THEN** a ProductListPage e renderizada dentro do MainLayout

#### Scenario: DISPATCHER acessa rota de entregadores
- **WHEN** um usuario DISPATCHER navega para `/couriers`
- **THEN** a CouriersPage e renderizada dentro do MainLayout

#### Scenario: OPERATOR tenta acessar relatorios
- **WHEN** um usuario OPERATOR navega para `/reports`
- **THEN** o acesso e negado (somente ADMIN)

### Requirement: Rotas usam MainLayout
Todas as rotas autenticadas SHALL usar o `MainLayout` (Sidebar + Header + Content area) como layout pai via React Router layout route pattern.

#### Scenario: Pagina renderiza dentro do layout
- **WHEN** o usuario acessa `/dashboard`
- **THEN** a DashboardPage e renderizada dentro do MainLayout com Sidebar e Header visiveis

### Requirement: Paginas placeholder
Cada rota SHALL ter uma pagina placeholder minima que renderiza o titulo da pagina. As paginas SHALL estar nos locais finais (`src/features/*/pages/`) para evitar movimentacao de arquivos futura.

#### Scenario: Placeholder renderiza titulo
- **WHEN** o usuario acessa `/products`
- **THEN** a pagina exibe "Produtos" como titulo
