## Context

A DashboardPage ja existe com KPIs, graficos de barras/pizza e lista de pedidos ativos (implementada em sessao anterior). O backend expoe 3 endpoints de reports para ADMIN: `/api/reports/sales` (com startDate/endDate), `/api/reports/products/top-selling` (com limit) e `/api/reports/metrics`. A ReportsPage e apenas um placeholder com `<PageHeader title="Relatorios" />`.

O `SalesReportResponse` do backend retorna: startDate, endDate, totalOrders, totalRevenue, averageOrderValue, deliveredOrders, cancelledOrders. O `TopProductResponse` retorna: productId, productName, totalQuantitySold, totalRevenue.

## Goals / Non-Goals

**Goals:**
- Implementar ReportsPage completa com filtro de data, metricas, tabela de vendas, grafico de evolucao e top produtos
- Reutilizar componentes UI existentes (Table, Spinner, EmptyState, Badge, PageHeader)
- Tipar corretamente os DTOs do backend

**Non-Goals:**
- Modificar DashboardPage (ja implementada)
- Exportacao de relatorios em CSV/PDF
- Graficos interativos com drill-down

## Decisions

### 1. DateRangePicker com inputs nativos
Usar dois `<input type="date">` com estado local e botao "Filtrar". Simples e sem dependencia adicional. O periodo padrao sera os ultimos 7 dias.

**Alternativa**: Lib de date picker (react-datepicker) — descartada para evitar dependencia extra.

### 2. Metricas via endpoint `/api/reports/metrics`
O endpoint `/api/reports/metrics` retorna `SalesReportResponse` (mesma shape), porem com dados globais (sem filtro de data). Usar para os cards de metricas no topo.

### 3. LineChart com dados do SalesReport
O endpoint `/api/reports/sales` retorna dados agregados do periodo, nao por dia. Como nao ha endpoint de vendas por dia, exibir os dados do SalesReport como cards detalhados ao inves de LineChart. Se futuramente o backend expuser dados diarios, o grafico pode ser adicionado.

### 4. TopSellingProducts como tabela rankeada
Exibir os top produtos como tabela com ranking, nome, quantidade vendida e receita. Usar o componente Table existente.

## Risks / Trade-offs

- **[Sem dados diarios]** O backend nao expoe vendas por dia, apenas agregado por periodo. O LineChart da spec original nao e possivel com a API atual. → Substituir por exibicao de metricas detalhadas do periodo. Documentar como melhoria futura.
- **[Date inputs]** Inputs nativos de data tem aparencia inconsistente entre navegadores. → Aceitavel para escopo academico; desktop-first.
