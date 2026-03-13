## Context

O frontend já possui layout, roteamento, componentes UI e autenticação Keycloak implementados. A `DashboardPage` é um stub (`<PageHeader title="Dashboard" />`). O backend expõe `GET /api/reports/dashboard` e `GET /api/orders/active`. As dependências `recharts` e `@tanstack/react-query` já estão instaladas.

## Goals / Non-Goals

**Goals:**
- Implementar `DashboardPage` com KPIs, gráficos Recharts e lista de pedidos ativos
- Criar hooks TanStack Query para `useDashboard` e `useActiveOrders`
- Reutilizar componentes UI existentes (`Spinner`, `EmptyState`, `StatusBadge`)

**Non-Goals:**
- Polling de pedidos (responsabilidade da feature de Pedidos)
- Notificações de novos pedidos (feature separada)
- ReportsPage (será implementada na feature de Relatórios)

## Decisions

### Estrutura de dados do endpoint `/api/reports/dashboard`
O tipo `DashboardData` será inferido do contrato do backend e incluirá: `totalOrdersToday`, `averageTicket`, `activeOrdersCount`, `activeCouriersCount`, `salesLast7Days` (array com `date` e `total`) e `topProducts` (array com `name` e `quantity`).

### Separação de hooks
`useDashboard` busca dados agregados de relatório. `useActiveOrders` busca lista de pedidos em andamento. São separados pois têm endpoints distintos e a lista de pedidos ativos será reutilizada na feature de Pedidos.

### Gráficos Recharts com `ResponsiveContainer`
Todos os gráficos usam `ResponsiveContainer` para adaptar ao container pai, sem largura fixa.

### Fallback de loading/erro
Enquanto carrega, exibe `Spinner` centralizado. Em erro, exibe mensagem genérica via `EmptyState`.

## Risks / Trade-offs

- [Contrato da API desconhecido] → Os campos do `DashboardData` podem diferir do esperado. Mitigation: tipar com `unknown` nos campos opcionais e usar optional chaining na renderização.
- [Recharts em SSR] → Não aplicável (Vite/CSR).
