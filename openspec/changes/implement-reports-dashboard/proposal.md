## Why

A DashboardPage ja esta implementada com KPIs, graficos e lista de pedidos ativos. Porem a ReportsPage (`/reports`, somente ADMIN) e apenas um placeholder com titulo. O backoffice precisa de relatorios detalhados com filtro de data para que o admin analise vendas, metricas e produtos mais vendidos em periodos especificos.

## What Changes

- Criar tipos TypeScript para os DTOs de reports (`SalesReportResponse`, `TopProductResponse`, `MetricsData`)
- Criar hooks TanStack Query: `useSalesReport`, `useTopSellingProducts`, `useMetrics`
- Criar componente `DateRangePicker` para selecao de periodo
- Criar componente `MetricsCards` com cards de metricas (total pedidos, faturamento, ticket medio, taxa aceitacao)
- Criar componente `SalesReportTable` com tabela de vendas do periodo
- Criar componente `TopSellingProducts` com lista de produtos mais vendidos
- Implementar `ReportsPage` completa com todos os componentes, graficos Recharts (LineChart) e loading/empty states

## Capabilities

### New Capabilities

### Modified Capabilities
- `reports-dashboard`: Implementacao da ReportsPage com hooks, componentes e graficos (DashboardPage ja esta completa)

## Impact

- **Codigo afetado**: `features/reports/pages/ReportsPage.tsx` (substituir placeholder)
- **Novo diretorio**: `features/reports/components/`, `features/reports/hooks/`, `features/reports/types/`
- **Dependencias existentes**: Recharts, TanStack Query, date-fns (ja instalados)
- **Backend**: Consome endpoints `GET /api/reports/sales`, `GET /api/reports/products/top-selling`, `GET /api/reports/metrics`
