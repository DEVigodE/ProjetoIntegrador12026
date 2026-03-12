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

### Requirement: ReportsPage com filtro de data
O sistema SHALL exibir em `ReportsPage` um `DateRangePicker` para selecionar periodo, e os dados de relatorio sao filtrados pelo periodo selecionado.

#### Scenario: Filtrar por periodo
- **WHEN** o usuario seleciona um periodo de 01/03 a 10/03
- **THEN** os dados de vendas sao filtrados para esse periodo via `GET /api/reports/sales?startDate=&endDate=`

### Requirement: Tabela de vendas por dia
O sistema SHALL exibir uma tabela de relatorio de vendas agrupada por dia.

#### Scenario: Tabela de vendas
- **WHEN** o ReportsPage carrega com periodo selecionado
- **THEN** uma tabela com vendas por dia e exibida

### Requirement: Grafico de evolucao de pedidos
O sistema SHALL exibir um grafico de linha (Recharts `LineChart`) mostrando a evolucao de pedidos no periodo selecionado.

#### Scenario: Grafico de linha renderiza
- **WHEN** o ReportsPage carrega
- **THEN** um grafico de linha com evolucao de pedidos e exibido

### Requirement: Cards de metricas
O sistema SHALL exibir cards de metricas: total de pedidos, total faturado, ticket medio e taxa de aceitacao.

#### Scenario: Metricas exibidas
- **WHEN** o ReportsPage carrega
- **THEN** os cards de metricas sao exibidos com dados de `GET /api/reports/metrics`

### Requirement: Top produtos mais vendidos
O sistema SHALL exibir uma lista dos produtos mais vendidos no periodo via `GET /api/reports/products/top-selling`.

#### Scenario: Top produtos exibidos
- **WHEN** o ReportsPage carrega
- **THEN** a lista de top produtos e exibida

### Requirement: Hooks TanStack Query para reports
O sistema SHALL implementar os seguintes hooks:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useDashboard` | GET | `/api/reports/dashboard` |
| `useSalesReport` | GET | `/api/reports/sales?startDate=&endDate=` |
| `useTopSellingProducts` | GET | `/api/reports/products/top-selling` |
| `useMetrics` | GET | `/api/reports/metrics` |

#### Scenario: Dashboard hook carrega dados
- **WHEN** DashboardPage monta
- **THEN** `useDashboard` faz GET /api/reports/dashboard e retorna os dados
