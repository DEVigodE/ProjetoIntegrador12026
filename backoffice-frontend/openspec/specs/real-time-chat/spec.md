# Real-Time Chat

Chat em tempo real via WebSocket/STOMP, embutido nos detalhes do pedido.

## Requirements

### Requirement: Cliente STOMP singleton
O sistema SHALL ter um servico singleton em `src/services/websocket.ts` que cria e gerencia uma instancia do `@stomp/stompjs` Client, conectando via SockJS ao endpoint `VITE_WS_URL` com token de autenticacao.

#### Scenario: Cliente STOMP criado
- **WHEN** chamar `getStompClient()`
- **THEN** retorna uma instancia Client configurada com `webSocketFactory` usando SockJS e `reconnectDelay: 5000`

#### Scenario: Token enviado na conexao
- **WHEN** o cliente STOMP conecta
- **THEN** a URL inclui `?token={keycloak.token}` para autenticacao

### Requirement: Hook useChatWebSocket
O sistema SHALL ter um hook `useChatWebSocket(orderId)` que:
1. Ativa o cliente STOMP na montagem
2. Subscribe em `/topic/chat/{orderId}`
3. Ao receber mensagem, adiciona ao estado local
4. Expoe funcao `sendMessage()` que publica em `/app/chat/{orderId}/send`
5. Desconecta na desmontagem

#### Scenario: Receber mensagem em tempo real
- **WHEN** uma nova mensagem e publicada no topico `/topic/chat/{orderId}`
- **THEN** a mensagem aparece imediatamente na lista de mensagens do ChatPanel

#### Scenario: Enviar mensagem
- **WHEN** o usuario digita uma mensagem e clica em enviar
- **THEN** a mensagem e publicada em `/app/chat/{orderId}/send` via STOMP

#### Scenario: Desconexao na desmontagem
- **WHEN** o componente que usa o hook e desmontado
- **THEN** o cliente STOMP desconecta do topico

### Requirement: Hook useChat (historico REST)
O sistema SHALL ter um hook `useChat(orderId)` que carrega o historico de mensagens via `GET /api/chat/{orderId}/messages`.

#### Scenario: Historico carregado
- **WHEN** o ChatPanel e montado
- **THEN** o historico de mensagens anteriores e carregado do backend via REST

### Requirement: ChatPanel component
O sistema SHALL ter um componente `ChatPanel` composto por `MessageList`, `MessageInput` e `MessageBubble`, exibido embutido nos detalhes do pedido.

#### Scenario: Chat renderiza
- **WHEN** o ChatPanel e montado com um orderId
- **THEN** o historico e carregado, o WebSocket conecta e mensagens sao exibidas

### Requirement: MessageBubble com tipos de remetente
O sistema SHALL diferenciar visualmente as mensagens por `senderType`:
- **STORE**: Alinhado a direita, cor primary
- **CUSTOMER**: Alinhado a esquerda, cor cinza
- **COURIER**: Alinhado a esquerda, cor azul
- **SYSTEM**: Centralizado, cor cinza claro, italico

#### Scenario: Mensagem da loja
- **WHEN** uma mensagem tem senderType='STORE'
- **THEN** o bubble e alinhado a direita com fundo primary

#### Scenario: Mensagem do sistema
- **WHEN** uma mensagem tem senderType='SYSTEM'
- **THEN** o bubble e centralizado, em italico, com fundo cinza claro

### Requirement: Tipos TypeScript do chat
O sistema SHALL definir os tipos em `chat.types.ts`:

```ts
type SenderType = 'STORE' | 'CUSTOMER' | 'COURIER' | 'SYSTEM';
interface MessageResponse { id: number; orderId: number; senderId: string; senderType: SenderType; content: string; sentAt: string; readAt: string | null; }
```

#### Scenario: Tipo SenderType correto
- **WHEN** o backend retorna uma mensagem
- **THEN** o senderType e um dos 4 valores validos

### Requirement: Notificacao de chat (Zustand store)
O sistema SHALL ter um `chatNotificationStore` (Zustand) que controla o badge de mensagens nao lidas.

#### Scenario: Badge de mensagem nao lida
- **WHEN** uma nova mensagem chega via WebSocket e o chat nao esta aberto
- **THEN** o badge de mensagens nao lidas e incrementado
