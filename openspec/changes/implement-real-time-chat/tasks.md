## 1. Tipos e Infraestrutura

- [ ] 1.1 Criar `features/chat/types/chat.types.ts` com SenderType e MessageResponse
- [ ] 1.2 Criar `src/services/websocket.ts` com singleton STOMP client (SockJS + token Keycloak)
- [ ] 1.3 Criar `src/store/chatNotificationStore.ts` com Zustand (unreadCount, increment, clear)

## 2. Hooks

- [ ] 2.1 Criar `features/chat/hooks/useChat.ts` — TanStack Query GET /api/chat/{orderId}/messages
- [ ] 2.2 Criar `features/chat/hooks/useChatWebSocket.ts` — STOMP subscribe/publish + estado local de mensagens

## 3. Componentes de Chat

- [ ] 3.1 Criar `features/chat/components/MessageBubble.tsx` com diferenciacao visual por senderType
- [ ] 3.2 Criar `features/chat/components/MessageList.tsx` com auto-scroll e empty state
- [ ] 3.3 Criar `features/chat/components/MessageInput.tsx` com envio via Enter e validacao de vazio
- [ ] 3.4 Criar `features/chat/components/ChatPanel.tsx` compondo hooks + MessageList + MessageInput com deduplicacao

## 4. Integracao nas Paginas de Pedido

- [ ] 4.1 Substituir placeholder de chat no OrderDetailPage.tsx pelo ChatPanel
- [ ] 4.2 Substituir placeholder de chat no OrderDetailModal.tsx pelo ChatPanel

## 5. Verificacao

- [ ] 5.1 Verificar compilacao TypeScript sem erros (npx tsc --noEmit)
