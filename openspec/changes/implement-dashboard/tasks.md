## 1. Tipos TypeScript

- [ ] 1.1 Criar `src/features/dashboard/hooks/dashboard.types.ts` com `DashboardData` (totalOrdersToday, averageTicket, activeOrdersCount, activeCouriersCount, salesLast7Days, topProducts)

## 2. Hooks TanStack Query

- [ ] 2.1 Criar `src/features/dashboard/hooks/useDashboard.ts` com `useQuery` para `GET /api/reports/dashboard`
- [ ] 2.2 Criar `src/features/orders/hooks/useActiveOrders.ts` com `useQuery` para `GET /api/orders/active`

## 3. Componentes do Dashboard

- [ ] 3.1 Criar `src/features/dashboard/components/KpiCard.tsx` com props: `title`, `value`, `icon?`, `subtitle?`
- [ ] 3.2 Criar `src/features/dashboard/components/SalesChart.tsx` com `ResponsiveContainer` + `BarChart` Recharts usando `salesLast7Days`
- [ ] 3.3 Criar `src/features/dashboard/components/TopProductsChart.tsx` com `ResponsiveContainer` + `PieChart` Recharts usando `topProducts`
- [ ] 3.4 Criar `src/features/dashboard/components/ActiveOrdersList.tsx` com lista de pedidos clicáveis, usando `StatusBadge` e navegando para `/orders/:id`

## 4. Página

- [ ] 4.1 Substituir stub de `src/features/dashboard/pages/DashboardPage.tsx` com layout em grid: 4 KPI cards no topo, gráfico de barras + gráfico de pizza lado a lado, lista de pedidos ativos abaixo
- [ ] 4.2 Adicionar estado de loading com `Spinner` e estado de erro com `EmptyState`
