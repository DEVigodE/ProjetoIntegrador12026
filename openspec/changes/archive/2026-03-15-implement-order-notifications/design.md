## Context

O `useActiveOrders` ja faz polling a cada 10s e retorna `Order[]`. O `orderNotificationStore` (Zustand) ja esta integrado no Sidebar com badge. O `AudioAlert` ja existe com Web Audio API. Falta apenas o hook de deteccao e a integracao nos componentes.

## Goals / Non-Goals

**Goals:**
- Detectar novos pedidos PENDING comparando resultados consecutivos do polling
- Disparar toast, som e incrementar badge quando novos pedidos sao detectados
- Limpar badge ao acessar pagina de pedidos

**Non-Goals:**
- WebSocket para notificacoes (usa polling existente)
- Notificacoes push do navegador
- Configuracao de preferencias de notificacao (ativar/desativar som)

## Decisions

### 1. Hook `useOrderNotifications` com ref para estado anterior
Usar `useRef` para armazenar os IDs dos pedidos PENDING da ultima consulta. A cada novo resultado do polling, comparar com o ref para identificar novos pedidos. Isso evita dependencia de estado adicional e re-renders desnecessarios.

**Alternativa**: Usar `onSuccess` callback do TanStack Query — descartada porque `onSuccess` foi deprecated no v5.

### 2. Integracao no OrdersPanel
O `OrdersPanel` ja consome `useActiveOrders`. Adicionar `useOrderNotifications(orders)` nele e renderizar `<AudioAlert play={hasNew} />` condicionalmente. O hook retorna `hasNewOrders` como flag para o AudioAlert.

### 3. Clear badge no OrdersPage
Chamar `clear()` do `orderNotificationStore` no `useEffect` de montagem do `OrdersPage`, garantindo que ao navegar para `/orders` o badge zere.

## Risks / Trade-offs

- **[False positives]** Se o polling retorna dados em ordem diferente, a comparacao por Set de IDs evita falsos positivos. → Mitigado pela comparacao por ID, nao por indice.
- **[AudioContext blocked]** Navegadores bloqueiam autoplay de audio ate interacao do usuario. O `AudioAlert` ja trata isso criando `AudioContext` apenas quando `play` muda. → Aceitavel; o usuario tera interagido com a pagina antes de receber pedidos.
