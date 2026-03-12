# Routing

Roteamento SPA com React Router v6, rotas protegidas por autenticacao e roles.

## Requirements

### Requirement: PrivateRoute guard
O sistema SHALL ter um componente `PrivateRoute` que redireciona para o login do Keycloak se o usuario nao estiver autenticado.

#### Scenario: Usuario nao autenticado
- **WHEN** um usuario nao autenticado acessa qualquer rota
- **THEN** ele e redirecionado para o Keycloak login

#### Scenario: Usuario autenticado
- **WHEN** um usuario autenticado acessa uma rota protegida
- **THEN** o conteudo da rota e renderizado

### Requirement: Rota raiz redireciona
O sistema SHALL redirecionar a rota `/` para `/dashboard`.

#### Scenario: Acesso a raiz
- **WHEN** o usuario acessa `/`
- **THEN** ele e redirecionado para `/dashboard`

### Requirement: Mapa completo de rotas
O sistema SHALL implementar as seguintes rotas com suas respectivas paginas e roles:

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
- **THEN** a ProductListPage e renderizada

#### Scenario: DISPATCHER acessa rota de entregadores
- **WHEN** um usuario DISPATCHER navega para `/couriers`
- **THEN** a CouriersPage e renderizada

#### Scenario: OPERATOR tenta acessar relatorios
- **WHEN** um usuario OPERATOR navega para `/reports`
- **THEN** o acesso e negado (somente ADMIN)

### Requirement: Rotas usam MainLayout
Todas as rotas autenticadas SHALL usar o `MainLayout` (Sidebar + Header + Content area) como layout pai.

#### Scenario: Pagina renderiza dentro do layout
- **WHEN** o usuario acessa `/dashboard`
- **THEN** a DashboardPage e renderizada dentro do MainLayout com Sidebar e Header visiveis
