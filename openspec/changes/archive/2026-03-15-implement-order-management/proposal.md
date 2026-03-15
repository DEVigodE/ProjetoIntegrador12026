## Why

O backoffice precisa de um painel de gerenciamento de pedidos para que a equipe do restaurante possa acompanhar, aceitar, recusar e atualizar o status dos pedidos em tempo real. Sem isso, nao ha como operar o fluxo de pedidos do delivery.

## What Changes

- Implementar painel Kanban em `OrdersPage` com colunas por status (PENDING, PREPARING, READY, OUT_FOR_DELIVERY)
- Criar `OrderDetailModal` com dados completos do pedido, timeline de status e acoes condicionais
- Implementar `OrderDetailPage` como pagina completa alternativa ao modal
- Criar `RejectOrderModal` para recusar pedidos com motivo
- Implementar lista secundaria filtravel com paginacao
- Criar componentes: `OrdersPanel`, `OrderCard`, `OrderTimeline`, `OrderFilters`, `OrderActions`
- Implementar hooks TanStack Query para todas as operacoes de pedidos (listagem, acoes de status)
- Adicionar utilitario `orderStatusLabel` para mapear enums para rotulos PT-BR com cores
- Placeholder para `ChatPanel` (implementacao completa na spec `real-time-chat`)

## Capabilities

### New Capabilities
- `orders`: Gerenciamento completo de pedidos — Kanban, detalhes, timeline, acoes por status, filtros, paginacao

### Modified Capabilities

## Impact

- **Codigo**: Novos arquivos em `src/features/orders/` (pages, components, hooks) e `src/utils/orderStatusLabel.ts`
- **Rotas**: Ativacao das rotas `/orders` e `/orders/:id` ja definidas no `App.tsx`
- **APIs consumidas**: `GET /api/orders`, `GET /api/orders/active`, `GET /api/orders/{id}`, `PATCH /api/orders/{id}/accept`, `PATCH /api/orders/{id}/reject`, `PATCH /api/orders/{id}/status`
- **Dependencias**: Nenhuma nova — usa componentes UI, TanStack Query, date-fns ja instalados
- **Codigo existente**: Reutiliza `order.types.ts` e `useActiveOrders.ts` ja criados na implementacao do dashboard
