## Context

O backoffice frontend ja possui OrderDetailPage e OrderDetailModal com placeholders de chat ("Chat disponivel em breve"). O backend expoe endpoints REST para historico de mensagens (`GET /api/chat/{orderId}/messages`) e WebSocket/STOMP (`/ws`) para comunicacao em tempo real. As dependencias `@stomp/stompjs`, `sockjs-client` e `zustand` ja estao instaladas no projeto.

Os componentes de pedidos estao em `features/orders/` e o chat sera uma feature separada em `features/chat/` para manter a separacao de responsabilidades.

## Goals / Non-Goals

**Goals:**
- Implementar chat funcional em tempo real nos detalhes do pedido
- Carregar historico de mensagens via REST na montagem do componente
- Diferenciar visualmente mensagens por tipo de remetente (STORE, CUSTOMER, COURIER, SYSTEM)
- Manter store de notificacoes de mensagens nao lidas
- Substituir placeholders de chat existentes nos componentes de pedidos

**Non-Goals:**
- Notificacoes push no navegador (apenas badge interno)
- Envio de arquivos/imagens no chat
- Indicador de "digitando..."
- Paginacao de historico de mensagens

## Decisions

### 1. Servico STOMP singleton em `src/services/websocket.ts`
Criar uma unica instancia do Client STOMP reutilizada por todo o app. A factory usa SockJS como fallback e injeta o token Keycloak na URL de conexao. O `reconnectDelay` de 5000ms garante reconexao automatica.

**Alternativa**: Criar cliente por componente — descartada pois multiplica conexoes desnecessariamente.

### 2. Dois hooks separados: `useChat` (REST) e `useChatWebSocket` (STOMP)
- `useChat(orderId)` usa TanStack Query para GET historico REST. Retorna `messages` iniciais.
- `useChatWebSocket(orderId)` gerencia conexao STOMP, subscribe no topico, e mantem estado local de mensagens recebidas em tempo real. Expoe `sendMessage(content)`.

**Alternativa**: Hook unico combinando REST + WebSocket — descartada por violar separacao de responsabilidades e dificultar testes.

### 3. Composicao do ChatPanel
O `ChatPanel` compoe internamente `MessageList` e `MessageInput`. A `MessageList` renderiza `MessageBubble` para cada mensagem. O ChatPanel combina mensagens do historico REST (useChat) com mensagens recebidas via WebSocket (useChatWebSocket), deduplicando por ID.

### 4. Integracao nas paginas de pedido
O `ChatPanel` substitui o placeholder dashed-border nos dois locais:
- `OrderDetailPage.tsx`: na area principal (col-span-2), abaixo das observacoes
- `OrderDetailModal.tsx`: abaixo da timeline, antes das acoes

### 5. Store Zustand para notificacoes de chat
`chatNotificationStore` com contagem de mensagens nao lidas. Incrementado quando uma mensagem chega via WebSocket e o chat daquele pedido nao esta visivel. Resetado ao abrir o chat do pedido.

## Risks / Trade-offs

- **[Reconexao WebSocket]** Se o servidor reiniciar, o STOMP client tenta reconectar a cada 5s. Mensagens perdidas durante a desconexao serao recuperadas quando o componente remontar (re-fetch REST). → Aceitavel para o escopo do projeto.
- **[Deduplicacao]** Mensagens enviadas pelo proprio usuario aparecem tanto via REST quanto WebSocket. Deduplicar por `id` no ChatPanel. → Simples de implementar.
- **[Token expirado]** O token Keycloak pode expirar durante uma sessao STOMP longa. O SockJS reconecta com URL contendo novo token. → O interceptor Axios ja trata refresh; o STOMP factory busca `keycloak.token` a cada reconexao.
