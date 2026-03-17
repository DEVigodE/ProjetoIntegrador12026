# Real-Time Chat

Chat em tempo real via WebSocket/STOMP embutido nos detalhes do pedido.

## Requirements

### Requirement: Tipos TypeScript do chat
O sistema SHALL definir os tipos em `features/chat/types/chat.types.ts`:
- `SenderType`: `'STORE' | 'CUSTOMER' | 'COURIER' | 'SYSTEM'`
- `MessageResponse`: id, orderId, senderId, senderType, content, sentAt, readAt (nullable)

#### Scenario: Tipo SenderType correto
- **WHEN** o backend retorna uma mensagem
- **THEN** o senderType e corretamente tipado como um dos 4 valores validos

### Requirement: Cliente STOMP singleton
O sistema SHALL implementar um servico singleton em `src/services/websocket.ts` que cria e gerencia uma instancia do `@stomp/stompjs` Client. O client SHALL usar `webSocketFactory` com SockJS conectando ao endpoint `VITE_WS_URL` com token Keycloak na URL e `reconnectDelay: 5000`.

#### Scenario: Cliente STOMP criado
- **WHEN** chamar `getStompClient()`
- **THEN** retorna uma instancia Client configurada com SockJS e reconnectDelay de 5000ms

#### Scenario: Token enviado na conexao
- **WHEN** o cliente STOMP conecta
- **THEN** a URL inclui `?token={keycloak.token}` para autenticacao

#### Scenario: Singleton reutilizado
- **WHEN** `getStompClient()` e chamado multiplas vezes
- **THEN** a mesma instancia e retornada

### Requirement: Hook useChat (historico REST)
O sistema SHALL implementar `useChat(orderId)` em `features/chat/hooks/useChat.ts` usando TanStack Query para carregar historico de mensagens via `GET /api/chat/{orderId}/messages`.

#### Scenario: Historico carregado
- **WHEN** o ChatPanel e montado com um orderId
- **THEN** o historico de mensagens anteriores e carregado do backend via REST

#### Scenario: Query key correta
- **WHEN** useChat e instanciado com orderId 42
- **THEN** a queryKey e `['chat', 42]`

### Requirement: Hook useChatWebSocket
O sistema SHALL implementar `useChatWebSocket(orderId)` em `features/chat/hooks/useChatWebSocket.ts` que:
1. Ativa o cliente STOMP na montagem (`client.activate()`)
2. Subscribe em `/topic/chat/{orderId}`
3. Ao receber mensagem, adiciona ao estado local e incrementa chatNotificationStore se o chat nao esta visivel
4. Expoe funcao `sendMessage(content)` que publica em `/app/chat/{orderId}/send` com payload `{ content }`
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

### Requirement: MessageBubble com tipos de remetente
O sistema SHALL implementar `MessageBubble` em `features/chat/components/MessageBubble.tsx` diferenciando visualmente por `senderType`:
- **STORE**: Alinhado a direita, fundo primary-500, texto branco
- **CUSTOMER**: Alinhado a esquerda, fundo gray-100, texto gray-900
- **COURIER**: Alinhado a esquerda, fundo blue-100, texto blue-900
- **SYSTEM**: Centralizado, fundo gray-50, texto gray-500, italico

Cada bubble SHALL exibir o horario formatado (HH:mm) abaixo do conteudo.

#### Scenario: Mensagem da loja
- **WHEN** uma mensagem tem senderType STORE
- **THEN** o bubble e alinhado a direita com fundo primary

#### Scenario: Mensagem do cliente
- **WHEN** uma mensagem tem senderType CUSTOMER
- **THEN** o bubble e alinhado a esquerda com fundo cinza

#### Scenario: Mensagem do entregador
- **WHEN** uma mensagem tem senderType COURIER
- **THEN** o bubble e alinhado a esquerda com fundo azul

#### Scenario: Mensagem do sistema
- **WHEN** uma mensagem tem senderType SYSTEM
- **THEN** o bubble e centralizado, em italico, com fundo cinza claro

### Requirement: MessageInput
O sistema SHALL implementar `MessageInput` em `features/chat/components/MessageInput.tsx` com campo de texto e botao enviar. O envio SHALL ocorrer ao clicar no botao ou pressionar Enter. O campo SHALL ser limpo apos envio. Mensagens vazias (apenas espacos) SHALL ser ignoradas.

#### Scenario: Envio via Enter
- **WHEN** o usuario digita texto e pressiona Enter
- **THEN** a mensagem e enviada e o campo e limpo

#### Scenario: Mensagem vazia ignorada
- **WHEN** o usuario tenta enviar mensagem com apenas espacos
- **THEN** nada acontece e o campo mantem o conteudo

### Requirement: MessageList
O sistema SHALL implementar `MessageList` em `features/chat/components/MessageList.tsx` que renderiza uma lista de `MessageBubble`. A lista SHALL fazer auto-scroll para o final quando novas mensagens chegam.

#### Scenario: Auto-scroll em nova mensagem
- **WHEN** uma nova mensagem e adicionada a lista
- **THEN** a lista rola automaticamente para o final

#### Scenario: Lista vazia
- **WHEN** nao ha mensagens
- **THEN** exibe texto "Nenhuma mensagem ainda"

### Requirement: ChatPanel completo
O sistema SHALL implementar `ChatPanel` em `features/chat/components/ChatPanel.tsx` que compoe `MessageList` e `MessageInput`. O ChatPanel SHALL:
1. Usar `useChat(orderId)` para carregar historico REST
2. Usar `useChatWebSocket(orderId)` para mensagens em tempo real
3. Combinar mensagens do historico e do WebSocket, deduplicando por ID
4. Exibir Spinner durante carregamento do historico
5. Ter altura fixa com overflow scroll na area de mensagens

#### Scenario: Chat renderiza completo
- **WHEN** o ChatPanel e montado com um orderId
- **THEN** o historico e carregado, o WebSocket conecta e mensagens sao exibidas

#### Scenario: Deduplicacao de mensagens
- **WHEN** uma mensagem aparece tanto no historico REST quanto via WebSocket
- **THEN** a mensagem e exibida apenas uma vez

### Requirement: Notificacao de chat (Zustand store)
O sistema SHALL implementar `chatNotificationStore` em `src/store/chatNotificationStore.ts` usando Zustand com:
- `unreadCount: number`
- `increment(): void`
- `clear(): void`

#### Scenario: Badge de mensagem nao lida
- **WHEN** uma nova mensagem chega via WebSocket e o chat nao esta aberto
- **THEN** o unreadCount e incrementado

#### Scenario: Limpar ao abrir chat
- **WHEN** o usuario abre o ChatPanel de um pedido
- **THEN** o unreadCount e resetado para 0
