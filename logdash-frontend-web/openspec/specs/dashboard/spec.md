# Dashboard

Pagina principal do backoffice com KPIs, graficos de vendas, grafico de top produtos e lista de pedidos ativos.

## Requirements

### Requirement: KPI Cards no DashboardPage
O sistema SHALL exibir 4 cards de KPI em `DashboardPage` com dados de `GET /api/reports/dashboard`: total de pedidos hoje, ticket médio, pedidos em andamento e entregadores ativos.

#### Scenario: KPI cards exibidos com dados reais
- **WHEN** o usuário acessa `/dashboard` e a requisição é bem-sucedida
- **THEN** 4 cards são exibidos com os valores retornados pelo endpoint

#### Scenario: Loading enquanto carrega
- **WHEN** a requisição ainda não retornou
- **THEN** um `Spinner` é exibido no lugar dos cards

### Requirement: Gráfico de barras de vendas
O sistema SHALL exibir um `BarChart` Recharts com as vendas dos últimos 7 dias usando `ResponsiveContainer` e dados do campo `salesLast7Days` da resposta de dashboard.

#### Scenario: Gráfico renderiza com dados
- **WHEN** o DashboardPage carrega com sucesso
- **THEN** um gráfico de barras com 7 colunas (uma por dia) é exibido

### Requirement: Gráfico de pizza de top produtos
O sistema SHALL exibir um `PieChart` Recharts com os top 5 produtos mais vendidos usando dados do campo `topProducts` da resposta de dashboard.

#### Scenario: Gráfico de pizza renderiza
- **WHEN** o DashboardPage carrega com sucesso
- **THEN** um gráfico de pizza com até 5 fatias é exibido com legenda de produto

### Requirement: Lista de pedidos ativos no dashboard
O sistema SHALL exibir uma lista de pedidos ativos via `GET /api/orders/active`, onde cada item é clicável e navega para `/orders/:id`.

#### Scenario: Clique no pedido navega para detalhe
- **WHEN** o usuário clica em um pedido da lista
- **THEN** é navegado para `/orders/:id`

#### Scenario: Lista vazia exibe EmptyState
- **WHEN** não há pedidos ativos
- **THEN** o componente `EmptyState` é exibido com mensagem "Nenhum pedido ativo"

### Requirement: Hook useDashboard
O sistema SHALL implementar `useDashboard` usando TanStack Query com `queryKey: ['dashboard']` que faz `GET /api/reports/dashboard` via instância Axios configurada.

#### Scenario: Hook retorna dados tipados
- **WHEN** `useDashboard` é chamado e a requisição tem sucesso
- **THEN** retorna `{ data: DashboardData, isLoading, isError }`

### Requirement: Hook useActiveOrders no dashboard
O sistema SHALL implementar `useActiveOrders` usando TanStack Query com `queryKey: ['orders', 'active']` que faz `GET /api/orders/active`.

#### Scenario: Hook retorna lista de pedidos ativos
- **WHEN** `useActiveOrders` é chamado e a requisição tem sucesso
- **THEN** retorna array de `Order[]` com status ACCEPTED, PREPARING, READY ou OUT_FOR_DELIVERY
