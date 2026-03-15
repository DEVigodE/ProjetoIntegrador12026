## Why

O backoffice precisa de comunicacao em tempo real com clientes e entregadores durante o ciclo de vida de um pedido. Atualmente, os detalhes do pedido (OrderDetailPage e OrderDetailModal) exibem apenas um placeholder de chat. Implementar o chat via WebSocket/STOMP permite que operadores resolvam duvidas, informem atrasos e coordenem entregas sem sair do sistema.

## What Changes

- Criar servico singleton STOMP client (`src/services/websocket.ts`) com SockJS e autenticacao via token Keycloak
- Criar hook `useChatWebSocket(orderId)` para subscribe/publish em tempo real via STOMP
- Criar hook `useChat(orderId)` para carregar historico de mensagens via REST (`GET /api/chat/{orderId}/messages`)
- Criar componentes `ChatPanel`, `MessageList`, `MessageInput` e `MessageBubble` na feature `chat/`
- Criar tipos TypeScript (`chat.types.ts`) com `SenderType` e `MessageResponse`
- Criar store Zustand `chatNotificationStore` para badge de mensagens nao lidas
- Integrar `ChatPanel` nos detalhes do pedido (OrderDetailPage e OrderDetailModal), substituindo o placeholder atual

## Capabilities

### New Capabilities
- `real-time-chat`: Chat em tempo real via WebSocket/STOMP embutido nos detalhes do pedido, com historico REST, diferenciacao visual por tipo de remetente e notificacao de mensagens nao lidas

### Modified Capabilities
- `order-management`: Integracao do ChatPanel nos componentes OrderDetailPage e OrderDetailModal, substituindo o placeholder de chat existente

## Impact

- **Dependencias**: `@stomp/stompjs`, `sockjs-client`, `zustand` (ja instalados no projeto)
- **Backend**: Consome endpoints REST (`/api/chat/{orderId}/messages`) e WebSocket (`/ws` com STOMP)
- **Codigo afetado**: `features/orders/pages/OrderDetailPage.tsx`, `features/orders/components/OrderDetailModal.tsx` (integracao do ChatPanel)
- **Novo diretorio**: `src/features/chat/` (components, hooks, types)
- **Novo arquivo**: `src/services/websocket.ts`, `src/store/chatNotificationStore.ts`
