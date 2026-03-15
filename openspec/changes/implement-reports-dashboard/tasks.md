## 1. Tipos e Hooks

- [x] 1.1 Criar `features/reports/types/report.types.ts` com SalesReportData e TopProduct
- [x] 1.2 Criar `features/reports/hooks/useSalesReport.ts` — GET /api/reports/sales com startDate e endDate
- [x] 1.3 Criar `features/reports/hooks/useTopSellingProducts.ts` — GET /api/reports/products/top-selling
- [x] 1.4 Criar `features/reports/hooks/useMetrics.ts` — GET /api/reports/metrics

## 2. Componentes

- [x] 2.1 Criar `features/reports/components/DateRangePicker.tsx` com inputs de data e botao Filtrar
- [x] 2.2 Criar `features/reports/components/MetricsCards.tsx` com cards de metricas
- [x] 2.3 Criar `features/reports/components/SalesReportTable.tsx` com tabela de vendas do periodo
- [x] 2.4 Criar `features/reports/components/TopSellingProducts.tsx` com tabela rankeada

## 3. Pagina

- [x] 3.1 Implementar `ReportsPage.tsx` completa com todos os componentes, loading e empty states

## 4. Verificacao

- [x] 4.1 Verificar compilacao TypeScript sem erros (npx tsc --noEmit)
