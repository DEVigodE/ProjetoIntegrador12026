# Order Notifications

Deteccao de novos pedidos PENDING via polling e disparo de notificacoes.

## ADDED Requirements

### Requirement: Hook useOrderNotifications
O sistema SHALL implementar `useOrderNotifications(orders)` em `features/orders/hooks/useOrderNotifications.ts` que:
1. Recebe o array de pedidos ativos do polling
2. Usa `useRef` para armazenar IDs de pedidos PENDING da ultima consulta
3. Compara com os IDs PENDING atuais para detectar novos
4. Para cada novo pedido PENDING: incrementa `orderNotificationStore` e dispara toast via React Toastify
5. Retorna `hasNewOrders: boolean` (flag para AudioAlert, auto-reset apos 1s)

#### Scenario: Novo pedido detectado
- **WHEN** o polling retorna um pedido PENDING com ID que nao existia na consulta anterior
- **THEN** o store incrementa, toast e exibido e hasNewOrders retorna true

#### Scenario: Sem novos pedidos
- **WHEN** o polling retorna os mesmos pedidos PENDING
- **THEN** hasNewOrders retorna false e nenhuma notificacao e disparada

#### Scenario: Primeiro carregamento ignorado
- **WHEN** o hook e montado e recebe pedidos pela primeira vez
- **THEN** nenhuma notificacao e disparada (apenas inicializa o ref com os IDs atuais)

### Requirement: Toast de notificacao de pedido
O sistema SHALL exibir toast via React Toastify (posicao top-right) com texto "Novo pedido #{id}" quando um novo pedido PENDING e detectado.

#### Scenario: Toast exibido com ID do pedido
- **WHEN** um novo pedido PENDING com id=42 e detectado
- **THEN** um toast e exibido com "Novo pedido #42"

### Requirement: Alerta sonoro integrado
O sistema SHALL renderizar `AudioAlert` no `OrdersPanel` com prop `play` controlada pelo `hasNewOrders` retornado do `useOrderNotifications`.

#### Scenario: Som tocado ao detectar novo pedido
- **WHEN** hasNewOrders muda para true
- **THEN** o AudioAlert reproduz o som de notificacao

### Requirement: Badge limpo ao acessar pedidos
O sistema SHALL chamar `orderNotificationStore.clear()` quando o `OrdersPage` e montado, zerando o badge no Sidebar.

#### Scenario: Badge zerado ao navegar
- **WHEN** o usuario navega para `/orders`
- **THEN** o pendingCount do store e zerado e o badge desaparece do Sidebar
