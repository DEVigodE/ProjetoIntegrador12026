## Why

O backoffice precisa alertar operadores sobre novos pedidos PENDING em tempo real para garantir atendimento rapido. A infraestrutura base ja existe (polling a cada 10s via `useActiveOrders`, store Zustand `orderNotificationStore`, componente `AudioAlert`, badge no Sidebar), mas falta o hook de deteccao que compara resultados do polling para identificar novos pedidos e disparar as notificacoes (toast, som, badge).

## What Changes

- Criar hook `useOrderNotifications` que detecta novos pedidos PENDING comparando polling anterior/atual
- Ao detectar novos pedidos: disparar toast (React Toastify), tocar som (AudioAlert), incrementar badge (orderNotificationStore)
- Integrar o hook e AudioAlert no `OrdersPanel` (Kanban) que ja consome `useActiveOrders`
- Limpar badge ao acessar `/orders` via `clear()` do store

## Capabilities

### New Capabilities
- `order-notifications`: Deteccao de novos pedidos PENDING via polling e disparo de notificacoes (toast, som, badge)

### Modified Capabilities

## Impact

- **Codigo afetado**: `features/orders/components/OrdersPanel.tsx` (integracao do hook + AudioAlert)
- **Codigo afetado**: `features/orders/pages/OrdersPage.tsx` (clear badge on mount)
- **Novo arquivo**: `features/orders/hooks/useOrderNotifications.ts`
- **Dependencias existentes**: React Toastify, Zustand, Web Audio API (ja instalados)
