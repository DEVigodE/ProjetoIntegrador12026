## MODIFIED Requirements

### Requirement: MainLayout com tres areas
O sistema SHALL ter um `MainLayout` composto por Sidebar fixa a esquerda, Header no topo e area de conteudo principal que renderiza a pagina ativa via `<Outlet />` do React Router. O MainLayout SHALL ser usado como layout route no React Router, envolvendo todas as rotas autenticadas.

#### Scenario: Layout renderiza corretamente
- **WHEN** o usuario esta autenticado e acessa qualquer pagina
- **THEN** o Sidebar e exibido a esquerda, o Header no topo e o conteudo da pagina no centro/direita

#### Scenario: Layout usa Outlet do React Router
- **WHEN** o usuario navega entre paginas
- **THEN** apenas o conteudo dentro do `<Outlet />` muda, enquanto Sidebar e Header permanecem fixos

### Requirement: Sidebar com navegacao por role
O sistema SHALL exibir um menu lateral (`Sidebar`) com fundo `slate-800`, texto branco, e item ativo destacado com cor `primary-500`. Os itens do menu SHALL ser filtrados pela role do usuario. Os itens de navegacao SHALL ser definidos como uma configuracao estatica com `{ path, label, roles }` e filtrados em tempo de renderizacao.

#### Scenario: Itens do menu para ADMIN
- **WHEN** um usuario ADMIN visualiza o Sidebar
- **THEN** ele ve: Dashboard, Pedidos, Produtos, Entregadores, Entregas, Relatorios, Configuracoes, Sair

#### Scenario: Itens do menu para OPERATOR
- **WHEN** um usuario OPERATOR visualiza o Sidebar
- **THEN** ele ve: Dashboard, Pedidos, Produtos, Sair

#### Scenario: Itens do menu para DISPATCHER
- **WHEN** um usuario DISPATCHER visualiza o Sidebar
- **THEN** ele ve: Entregadores, Entregas, Sair

#### Scenario: Item ativo destacado
- **WHEN** o usuario esta na pagina `/products`
- **THEN** o item "Produtos" no Sidebar esta destacado com cor primary-500

#### Scenario: Badge de notificacao em Pedidos
- **WHEN** existem pedidos pendentes (pendingCount > 0 no orderNotificationStore)
- **THEN** o item "Pedidos" exibe um badge vermelho com o numero de pedidos pendentes

### Requirement: Header com informacoes do usuario
O sistema SHALL exibir um Header com fundo branco e sombra suave contendo: titulo da pagina atual, area de notificacoes e nome do usuario com botao de logout.

#### Scenario: Nome do usuario exibido
- **WHEN** o usuario esta autenticado
- **THEN** o Header exibe o nome do usuario lido de `keycloak.tokenParsed?.name`

#### Scenario: Botao de logout funciona
- **WHEN** o usuario clica em "Sair" no Header
- **THEN** `keycloak.logout()` e chamado e o usuario e redirecionado para o Keycloak

### Requirement: PageHeader com titulo e breadcrumb
O sistema SHALL ter um componente `PageHeader` que exibe o titulo da pagina atual e opcionalmente um breadcrumb.

#### Scenario: Titulo da pagina
- **WHEN** o usuario esta em `/products`
- **THEN** o PageHeader exibe "Produtos" como titulo

### Requirement: AuthLayout para loading
O sistema SHALL ter um `AuthLayout` minimalista exibido enquanto o Keycloak esta inicializando, com spinner e texto "Autenticando...".

#### Scenario: Loading de autenticacao
- **WHEN** o Keycloak esta inicializando
- **THEN** o AuthLayout com spinner e exibido
