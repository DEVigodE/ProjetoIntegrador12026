## 1. Utilitarios e Infraestrutura

- [x] 1.1 Criar `src/utils/orderStatusLabel.ts` com funcoes `getStatusLabel(status)` e `getStatusColor(status)` mapeando OrderStatus para rotulo PT-BR e variante de cor do Badge

## 2. Hooks TanStack Query

- [x] 2.1 Criar `useOrders` — GET `/api/orders` com filtros de status e paginacao
- [x] 2.2 Criar `useOrder` — GET `/api/orders/{id}` para detalhes do pedido
- [x] 2.3 Criar `useAcceptOrder` — PATCH `/api/orders/{id}/accept` com invalidacao de queries
- [x] 2.4 Criar `useRejectOrder` — PATCH `/api/orders/{id}/reject` com motivo e invalidacao
- [x] 2.5 Criar `useUpdateOrderStatus` — PATCH `/api/orders/{id}/status` com novo status e invalidacao

## 3. Componentes de Pedidos

- [x] 3.1 Criar `OrderCard` — card compacto com #id, nome cliente, valor BRL, tempo relativo (date-fns) e badge de status
- [x] 3.2 Criar `OrdersPanel` — painel Kanban com 4 colunas agrupando pedidos ativos por status
- [x] 3.3 Criar `OrderFilters` — select de status e controles de paginacao para a visao em lista
- [x] 3.4 Criar `OrderTimeline` — stepper vertical com passos do ciclo de vida, checks verdes para completados, destaque para atual
- [x] 3.5 Criar `OrderActions` — botoes condicionais por status (aceitar, recusar, iniciar preparo, pronto, saiu entrega, finalizar)
- [x] 3.6 Criar `RejectOrderModal` — modal com campo de motivo obrigatorio e confirmacao com loading
- [x] 3.7 Criar `OrderDetailModal` — modal com dados completos, OrderTimeline, OrderActions e placeholder de chat

## 4. Paginas

- [x] 4.1 Implementar `OrdersPage` — tabs Kanban/Lista, OrdersPanel, tabela paginada com OrderFilters, abertura de OrderDetailModal
- [x] 4.2 Implementar `OrderDetailPage` — pagina completa com dados do pedido, OrderTimeline, OrderActions e placeholder de chat
