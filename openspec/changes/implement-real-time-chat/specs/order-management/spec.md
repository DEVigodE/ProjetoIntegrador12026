# Order Management (delta)

## MODIFIED Requirements

### Requirement: Chat embutido no detalhe do pedido
O sistema SHALL exibir o `ChatPanel` (de `features/chat/components/ChatPanel.tsx`) embutido no `OrderDetailModal` e `OrderDetailPage`, substituindo o placeholder atual. O ChatPanel SHALL receber o `orderId` do pedido e conectar automaticamente ao canal WebSocket.

#### Scenario: Chat funcional no detalhe do pedido
- **WHEN** o usuario abre detalhes de um pedido
- **THEN** o ChatPanel e exibido com historico de mensagens e possibilidade de enviar novas mensagens em tempo real

#### Scenario: Chat no modal de detalhes
- **WHEN** o usuario abre o OrderDetailModal de um pedido
- **THEN** o ChatPanel e exibido abaixo da timeline com funcionalidade completa
