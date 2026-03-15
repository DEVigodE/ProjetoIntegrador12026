## Context

O frontend ja possui tipos (`Order`, `OrderStatus`, `OrderItem`) e o hook `useActiveOrders` criados durante a implementacao do dashboard. As paginas `OrdersPage` e `OrderDetailPage` existem como stubs. Componentes UI reutilizaveis (Table, Modal, Badge, Button, Pagination, ConfirmDialog, Spinner, EmptyState) estao disponiveis. O utilitario `StatusBadge` existe em `components/shared/`.

O backend expoe endpoints REST completos para pedidos com paginacao, filtros por status e acoes de transicao de estado. O ciclo de vida segue: PENDING → ACCEPTED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED (com CANCELLED como estado terminal).

## Goals / Non-Goals

**Goals:**
- Implementar painel Kanban para visualizacao rapida de pedidos ativos por status
- Permitir acoes de transicao de status diretamente do Kanban e dos detalhes
- Exibir detalhes completos do pedido com timeline de historico
- Permitir recusa de pedidos com motivo obrigatorio
- Implementar lista filtravel como visao alternativa ao Kanban
- Criar utilitario de mapeamento status → rotulo PT-BR + cor

**Non-Goals:**
- Chat em tempo real embutido no detalhe (sera feito na spec `real-time-chat` — apenas placeholder)
- Notificacoes sonoras de novos pedidos (sera feito na spec `order-notifications`)
- Atribuicao de entregador no status READY (sera feito na spec `delivery-management`)
- Drag-and-drop entre colunas do Kanban

## Decisions

### 1. Kanban como visao principal, lista como secundaria

A `OrdersPage` exibe o painel Kanban por padrao (visao operacional rapida) com tabs ou toggle para alternar para a visao em lista filtravel. O Kanban mostra apenas pedidos ativos (PENDING, ACCEPTED, PREPARING, READY, OUT_FOR_DELIVERY). A lista mostra todos os pedidos com paginacao.

**Alternativa descartada**: Apenas lista — nao atende ao fluxo operacional onde o operador precisa ver todos os status simultaneamente.

### 2. Modal para detalhes rapidos, pagina para detalhes completos

Clicar em um card no Kanban abre `OrderDetailModal` (visao rapida inline). A rota `/orders/:id` abre `OrderDetailPage` (visao completa). Ambos compartilham os mesmos componentes internos (OrderInfo, OrderTimeline, OrderActions).

### 3. Acoes condicionais por status com hook dedicado

Cada acao de transicao tem seu proprio mutation hook (`useAcceptOrder`, `useRejectOrder`, `useUpdateOrderStatus`). Os botoes de acao sao renderizados condicionalmente pelo componente `OrderActions` baseado no `status` atual.

### 4. Polling a cada 10s para pedidos ativos

O `useActiveOrders` (ja existente) usa `refetchInterval: 10_000` para manter o Kanban atualizado. A lista paginada nao usa polling (usuario controla via refresh manual ou filtros).

### 5. Timeline como componente visual de stepper

`OrderTimeline` exibe os passos do ciclo de vida como um stepper vertical. Passos completados mostram timestamp, passo atual tem destaque visual, passos futuros ficam desabilitados. Usa `createdAt` e `updatedAt` do pedido.

### 6. Placeholder para ChatPanel

O detalhe do pedido reserva espaco para o `ChatPanel` mas renderiza apenas um placeholder ("Chat disponivel em breve") ate a spec `real-time-chat` ser implementada.

## Risks / Trade-offs

- **[Polling vs WebSocket para Kanban]** → Usamos polling a cada 10s por simplicidade. Trade-off: delay de ate 10s para novos pedidos. Mitigacao aceitavel para MVP; WebSocket pode ser adicionado depois.
- **[Modal vs Pagina para detalhes]** → Manter ambos adiciona complexidade mas atende dois fluxos de uso (rapido no Kanban, completo via URL). Mitigacao: compartilhar componentes internos.
- **[Timeline sem historico real]** → O backend retorna apenas `createdAt` e `updatedAt`, sem historico de transicoes individual. A timeline mostra status atual como "completado" e anteriores inferidos. Mitigacao: atualizar quando backend adicionar endpoint de historico.
