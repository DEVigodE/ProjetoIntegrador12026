## Why

A DashboardPage existe como stub e não exibe nenhuma informação útil. É a primeira tela que qualquer usuário vê ao entrar no sistema, e precisa fornecer uma visão geral operacional imediata: KPIs do dia, gráficos de vendas e pedidos ativos.

## What Changes

- Implementar `DashboardPage` completa substituindo o stub atual
- Criar componentes `KpiCard`, `SalesChart`, `TopProductsChart`, `ActiveOrdersList`
- Criar hook `useDashboard` consumindo `GET /api/reports/dashboard`
- Criar hook `useActiveOrders` consumindo `GET /api/orders/active`

## Capabilities

### New Capabilities

- `dashboard`: Página de dashboard com KPI cards, gráfico de barras de vendas (últimos 7 dias), gráfico de pizza de top 5 produtos e lista de pedidos ativos clicáveis

### Modified Capabilities

_(nenhuma)_

## Impact

- `src/features/dashboard/pages/DashboardPage.tsx` — substituído
- `src/features/dashboard/components/` — novos: KpiCard, SalesChart, TopProductsChart, ActiveOrdersList
- `src/features/dashboard/hooks/` — novos: useDashboard, useActiveOrders
- Dependências já instaladas: `recharts`, `@tanstack/react-query`, `axios`
