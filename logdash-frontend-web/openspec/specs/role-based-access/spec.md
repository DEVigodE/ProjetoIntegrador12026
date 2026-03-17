# Role-Based Access

Controle de acesso por roles extraidas do JWT Keycloak (realm_access.roles).

## Requirements

### Requirement: Tres roles de sistema
O sistema SHALL reconhecer tres roles: ADMIN, OPERATOR, DISPATCHER, extraidas do claim `realm_access.roles` do token JWT.

#### Scenario: Roles extraidas do token
- **WHEN** o usuario autentica com sucesso
- **THEN** as roles sao lidas de `keycloak.tokenParsed.realm_access.roles`

### Requirement: Hook useRoles
O sistema SHALL prover um hook `useRoles()` que retorna as roles do usuario autenticado e um hook `useHasRole(role)` que verifica se o usuario possui uma role especifica.

#### Scenario: useRoles retorna roles do usuario
- **WHEN** chamar `useRoles()` com um usuario ADMIN logado
- **THEN** o array retornado contem 'ADMIN'

#### Scenario: useHasRole verifica role
- **WHEN** chamar `useHasRole('OPERATOR')` com um usuario OPERATOR logado
- **THEN** retorna `true`

#### Scenario: useHasRole para role inexistente
- **WHEN** chamar `useHasRole('DISPATCHER')` com um usuario OPERATOR logado
- **THEN** retorna `false`

### Requirement: RoleGuard component
O sistema SHALL ter um componente `RoleGuard` que renderiza children somente se o usuario possui uma das roles exigidas. Caso contrario, exibe mensagem de acesso negado ou redireciona.

#### Scenario: Usuario com role permitida
- **WHEN** um usuario ADMIN acessa uma rota protegida com `roles={['ADMIN']}`
- **THEN** o conteudo da rota e renderizado normalmente

#### Scenario: Usuario sem role permitida
- **WHEN** um usuario DISPATCHER acessa uma rota protegida com `roles={['ADMIN', 'OPERATOR']}`
- **THEN** o sistema exibe uma mensagem de "Acesso negado" ou redireciona para a pagina inicial

### Requirement: Permissoes por role
O sistema SHALL aplicar as seguintes permissoes por role:

- **ADMIN**: Acesso total — dashboard, produtos, pedidos, entregas, relatorios, configuracoes
- **OPERATOR**: Dashboard, produtos (CRUD), pedidos (aceitar/recusar/atualizar status), chat
- **DISPATCHER**: Entregas, entregadores (CRUD), atribuicao de entregador, chat

#### Scenario: ADMIN acessa tudo
- **WHEN** um usuario ADMIN navega pelo sistema
- **THEN** todas as paginas e acoes estao disponiveis

#### Scenario: OPERATOR nao acessa entregas
- **WHEN** um usuario OPERATOR tenta acessar `/couriers` ou `/deliveries`
- **THEN** o acesso e negado

#### Scenario: DISPATCHER nao acessa pedidos
- **WHEN** um usuario DISPATCHER tenta acessar `/orders` ou `/products`
- **THEN** o acesso e negado

### Requirement: Menu lateral filtrado por role
O sistema SHALL exibir apenas os itens de menu que o usuario tem permissao para acessar, baseado na sua role.

#### Scenario: Menu do OPERATOR
- **WHEN** um usuario OPERATOR visualiza o Sidebar
- **THEN** ele ve apenas: Dashboard, Produtos, Pedidos

#### Scenario: Menu do DISPATCHER
- **WHEN** um usuario DISPATCHER visualiza o Sidebar
- **THEN** ele ve apenas: Entregadores, Entregas

### Requirement: Usuarios de teste
O sistema SHALL funcionar com os seguintes usuarios de teste do Keycloak:

- `admin` / `admin123` — ADMIN
- `operador` / `operador123` — OPERATOR
- `despachante` / `despachante123` — DISPATCHER

#### Scenario: Login com usuario de teste
- **WHEN** o usuario `operador` faz login com senha `operador123`
- **THEN** ele autentica com sucesso e tem role OPERATOR
