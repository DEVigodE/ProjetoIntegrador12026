# Order Notifications

Notificacoes em tempo real de novos pedidos via polling, toasts, alertas sonoros e Zustand.

## Requirements

### Requirement: Polling a cada 10 segundos
O sistema SHALL usar TanStack Query com `refetchInterval: 10_000` no hook `useActiveOrders` para atualizar automaticamente a lista de pedidos ativos.

#### Scenario: Atualizacao automatica
- **WHEN** 10 segundos se passam desde a ultima consulta
- **THEN** `GET /api/orders/active` e chamado novamente automaticamente

### Requirement: Deteccao de novos pedidos PENDING
O sistema SHALL comparar o array retornado pelo polling com o estado anterior para detectar novos pedidos com status PENDING.

#### Scenario: Novo pedido detectado
- **WHEN** o polling retorna um pedido PENDING que nao existia na consulta anterior
- **THEN** o sistema dispara as notificacoes (toast + som + badge)

### Requirement: Toast de notificacao
O sistema SHALL disparar um toast visual via React Toastify (posicao top-right) quando um novo pedido PENDING e detectado.

#### Scenario: Toast exibido
- **WHEN** um novo pedido PENDING e detectado
- **THEN** um toast e exibido no canto superior direito com informacoes do pedido

### Requirement: Alerta sonoro
O sistema SHALL reproduzir um som de alerta via `AudioAlert` (Web Audio API) quando um novo pedido PENDING e detectado.

#### Scenario: Som tocado
- **WHEN** um novo pedido PENDING e detectado
- **THEN** um som de notificacao e reproduzido

### Requirement: Badge numerico no menu
O sistema SHALL atualizar o badge numerico no item "Pedidos" do Sidebar via Zustand (`orderNotificationStore`) quando novos pedidos PENDING sao detectados.

#### Scenario: Badge incrementado
- **WHEN** 2 novos pedidos PENDING sao detectados
- **THEN** o pendingCount do orderNotificationStore incrementa em 2 e o badge exibe o total

#### Scenario: Badge limpo ao acessar pedidos
- **WHEN** o usuario navega para `/orders`
- **THEN** o pendingCount e zerado via `clear()`

### Requirement: orderNotificationStore (Zustand)
O sistema SHALL ter um store Zustand com a interface:

```ts
interface OrderNotificationStore {
  pendingCount: number;
  setPendingCount: (count: number) => void;
  increment: () => void;
  clear: () => void;
}
```

#### Scenario: Store inicializa com zero
- **WHEN** o app inicia
- **THEN** `pendingCount` e 0

#### Scenario: Increment funciona
- **WHEN** chamar `increment()` com pendingCount=3
- **THEN** pendingCount muda para 4
