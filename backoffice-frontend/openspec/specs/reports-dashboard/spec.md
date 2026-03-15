# Reports & Dashboard

Dashboard com KPIs e graficos, e pagina de relatorios com filtros de data.

## Requirements

### Requirement: DashboardPage com KPIs
O sistema SHALL exibir em `DashboardPage` cards de KPI: total de pedidos hoje, ticket medio, pedidos em andamento e entregadores ativos. Os dados vem de `GET /api/reports/dashboard`.

#### Scenario: KPI cards exibidos
- **WHEN** o usuario acessa `/dashboard`
- **THEN** 4 cards de KPI sao exibidos com valores do endpoint de dashboard

### Requirement: Grafico de vendas dos ultimos 7 dias
O sistema SHALL exibir um grafico de barras (Recharts `BarChart`) mostrando vendas dos ultimos 7 dias.

#### Scenario: Grafico de barras renderiza
- **WHEN** o DashboardPage carrega
- **THEN** um grafico de barras com dados dos ultimos 7 dias e exibido

### Requirement: Grafico de top 5 produtos
O sistema SHALL exibir um grafico de pizza (Recharts `PieChart`) com os 5 produtos mais vendidos.

#### Scenario: Grafico de pizza renderiza
- **WHEN** o DashboardPage carrega
- **THEN** um grafico de pizza com top 5 produtos e exibido

### Requirement: Lista de pedidos ativos no dashboard
O sistema SHALL exibir uma lista resumida de pedidos ativos (em andamento) no dashboard, clicaveis para navegar ao detalhe.

#### Scenario: Pedido clicavel
- **WHEN** o usuario clica em um pedido ativo na lista do dashboard
- **THEN** ele e navegado para `/orders/:id`

### Requirement: Tipos TypeScript de reports
O sistema SHALL definir tipos em `features/reports/types/report.types.ts`:
- `SalesReportData`: startDate, endDate, totalOrders, totalRevenue, averageOrderValue, deliveredOrders, cancelledOrders
- `TopProduct`: productId, productName, totalQuantitySold, totalRevenue

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna dados via GET /api/reports/sales
- **THEN** a resposta e corretamente tipada como `SalesReportData`

### Requirement: Hooks TanStack Query para reports
O sistema SHALL implementar os seguintes hooks em `features/reports/hooks/`:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useDashboard` | GET | `/api/reports/dashboard` |
| `useSalesReport` | GET | `/api/reports/sales?startDate=&endDate=` |
| `useTopSellingProducts` | GET | `/api/reports/products/top-selling?limit=10` |
| `useMetrics` | GET | `/api/reports/metrics` |

O hook `useSalesReport` SHALL receber `startDate` e `endDate` como parametros e inclui-los na queryKey.

#### Scenario: Dashboard hook carrega dados
- **WHEN** DashboardPage monta
- **THEN** `useDashboard` faz GET /api/reports/dashboard e retorna os dados

#### Scenario: Sales report carrega com filtro de data
- **WHEN** `useSalesReport` e chamado com startDate=2026-03-01 e endDate=2026-03-10
- **THEN** GET /api/reports/sales?startDate=2026-03-01&endDate=2026-03-10 e executado

#### Scenario: Top selling products carrega
- **WHEN** `useTopSellingProducts` e chamado
- **THEN** GET /api/reports/products/top-selling?limit=10 e executado

### Requirement: DateRangePicker
O sistema SHALL implementar `DateRangePicker` em `features/reports/components/DateRangePicker.tsx` com dois inputs de data (inicio e fim) e botao "Filtrar". O periodo padrao SHALL ser os ultimos 7 dias. Ao clicar em "Filtrar", SHALL chamar callback `onFilter(startDate, endDate)`.

#### Scenario: Periodo padrao
- **WHEN** o DateRangePicker e montado
- **THEN** os inputs exibem os ultimos 7 dias como periodo padrao

#### Scenario: Filtrar por periodo
- **WHEN** o usuario seleciona datas e clica "Filtrar"
- **THEN** o callback onFilter e chamado com as datas selecionadas

### Requirement: MetricsCards
O sistema SHALL implementar `MetricsCards` em `features/reports/components/MetricsCards.tsx` exibindo cards com: total de pedidos, total faturado (BRL), ticket medio (BRL), pedidos entregues e pedidos cancelados. Os dados vem do `useMetrics`.

#### Scenario: Cards de metricas exibidos
- **WHEN** o ReportsPage carrega
- **THEN** 5 cards de metricas sao exibidos com dados do endpoint /api/reports/metrics

### Requirement: SalesReportTable
O sistema SHALL implementar `SalesReportTable` em `features/reports/components/SalesReportTable.tsx` exibindo uma tabela com os dados do periodo filtrado: total pedidos, faturamento, ticket medio, entregues e cancelados.

#### Scenario: Tabela de vendas exibida
- **WHEN** o usuario filtra por periodo
- **THEN** a tabela exibe os dados agregados do periodo

### Requirement: Grafico de evolucao de pedidos
O sistema SHALL exibir um grafico de linha (Recharts `LineChart`) mostrando a evolucao de pedidos no periodo selecionado.

#### Scenario: Grafico de linha renderiza
- **WHEN** o ReportsPage carrega
- **THEN** um grafico de linha com evolucao de pedidos e exibido

### Requirement: TopSellingProducts
O sistema SHALL implementar `TopSellingProducts` em `features/reports/components/TopSellingProducts.tsx` exibindo tabela rankeada com: posicao, nome do produto, quantidade vendida e receita total (BRL).

#### Scenario: Top produtos exibidos
- **WHEN** o ReportsPage carrega
- **THEN** a tabela exibe os 10 produtos mais vendidos com ranking

### Requirement: ReportsPage completa
O sistema SHALL implementar `ReportsPage` com PageHeader, DateRangePicker, MetricsCards, SalesReportTable e TopSellingProducts. Loading e empty states SHALL ser tratados. Somente ADMIN tem acesso (rota ja protegida por RoleGuard).

#### Scenario: Pagina completa
- **WHEN** o usuario ADMIN acessa `/reports`
- **THEN** a pagina exibe filtro de data, metricas, tabela de vendas e top produtos

#### Scenario: Loading state
- **WHEN** os dados estao carregando
- **THEN** Spinner e exibido
