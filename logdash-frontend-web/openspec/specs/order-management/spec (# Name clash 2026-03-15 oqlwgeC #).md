# Order Management

Gerenciamento de pedidos com painel Kanban, ciclo de vida de status e acoes.

## Requirements

### Requirement: Utilitario de mapeamento de status
O sistema SHALL implementar `src/utils/orderStatusLabel.ts` com funcoes para mapear `OrderStatus` para rotulo em PT-BR e variante de cor do Badge.

| Status | Rotulo | Cor |
|---|---|---|
| PENDING | Pendente | yellow |
| ACCEPTED | Aceito | blue |
| PREPARING | Em Preparo | yellow |
| READY | Pronto | green |
| OUT_FOR_DELIVERY | Saiu para Entrega | blue |
| DELIVERED | Entregue | green |
| CANCELLED | Cancelado | red |

#### Scenario: Status mapeado corretamente
- **WHEN** o frontend recebe um pedido com status `OUT_FOR_DELIVERY`
- **THEN** o rotulo exibido e "Saiu para Entrega" com badge azul

### Requirement: Enums de OrderStatus
O sistema SHALL usar os seguintes valores de enum (source of truth do backend Java):

`PENDING | ACCEPTED | PREPARING | READY | OUT_FOR_DELIVERY | DELIVERED | CANCELLED`

#### Scenario: Status mapeados corretamente
- **WHEN** o backend retorna um pedido com status "OUT_FOR_DELIVERY"
- **THEN** o frontend exibe o badge "Saiu para Entrega" (azul)

### Requirement: Tipos TypeScript de pedidos
O sistema SHALL definir os tipos em `order.types.ts`:

```ts
type OrderStatus = 'PENDING' | 'ACCEPTED' | 'PREPARING' | 'READY' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED';
interface OrderItem { id: number; productId: number; productName: string; unitPrice: number; quantity: number; subtotal: number; notes?: string; }
interface Order { id: number; status: OrderStatus; customerName: string; customerPhone: string; customerEmail?: string; deliveryStreet: string; deliveryNumber: string; deliveryComplement?: string; deliveryNeighborhood: string; deliveryCity: string; deliveryState: string; deliveryZipCode: string; totalAmount: number; notes?: string; rejectedReason?: string; items: OrderItem[]; createdAt: string; updatedAt: string; }
```

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna um pedido via GET /api/orders/{id}
- **THEN** a resposta e corretamente tipada como `Order`

### Requirement: Hooks TanStack Query para pedidos
O sistema SHALL implementar os seguintes hooks em `features/orders/hooks/`:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useOrders` | GET | `/api/orders?status=&page=&size=` |
| `useActiveOrders` | GET | `/api/orders/active` |
| `useOrder` | GET | `/api/orders/{id}` |
| `useAcceptOrder` | PATCH | `/api/orders/{id}/accept` |
| `useRejectOrder` | PATCH | `/api/orders/{id}/reject` |
| `useUpdateOrderStatus` | PATCH | `/api/orders/{id}/status` |

O hook `useActiveOrders` usa `refetchInterval: 10_000` para polling automatico.

#### Scenario: useOrders retorna lista paginada com filtro
- **WHEN** `useOrders` e chamado com `{ status: 'CANCELLED', page: 0, size: 20 }`
- **THEN** o hook retorna apenas pedidos cancelados com metadados de paginacao

#### Scenario: Mutation invalida queries relacionadas
- **WHEN** `useAcceptOrder` executa com sucesso
- **THEN** as queries `['orders']`, `['orders', 'active']` e `['order', id]` sao invalidadas

### Requirement: Painel Kanban de pedidos
O sistema SHALL exibir em `OrdersPage` um painel Kanban (`OrdersPanel`) com colunas: PENDING, ACCEPTED/PREPARING, READY, OUT_FOR_DELIVERY. Cada coluna SHALL exibir cards (`OrderCard`) com numero do pedido, nome do cliente, valor total e tempo relativo desde criacao (via date-fns `formatDistanceToNow`).

#### Scenario: Kanban renderiza com colunas
- **WHEN** o usuario acessa `/orders`
- **THEN** quatro colunas sao exibidas com os pedidos agrupados por status

#### Scenario: Card clicavel abre modal
- **WHEN** o usuario clica em um card de pedido no Kanban
- **THEN** o `OrderDetailModal` abre com os detalhes completos do pedido

#### Scenario: Kanban atualiza automaticamente
- **WHEN** 10 segundos se passam
- **THEN** o `useActiveOrders` refaz a query e o Kanban atualiza

### Requirement: OrderCard compacto
O sistema SHALL implementar `OrderCard` exibindo: numero do pedido (#id), nome do cliente, valor total formatado em BRL, tempo desde criacao e badge de status colorido.

#### Scenario: Card exibe informacoes resumidas
- **WHEN** um pedido com id=42, customerName="Joao", totalAmount=59.90, createdAt ha 5 minutos e exibido
- **THEN** o card mostra "#42", "Joao", "R$ 59,90" e "ha 5 minutos"

### Requirement: Lista de pedidos filtravel
O sistema SHALL exibir uma lista secundaria de todos os pedidos em `OrdersPage` (alternavel via tabs) com paginacao server-side e filtros por status (select com todos os valores de OrderStatus) usando o hook `useOrders`.

#### Scenario: Filtrar por status cancelado
- **WHEN** o usuario seleciona status "CANCELLED" no filtro
- **THEN** apenas pedidos cancelados sao exibidos na lista

#### Scenario: Paginacao funciona
- **WHEN** o usuario clica na pagina 2
- **THEN** a query e refeita com `page=1`

### Requirement: Detalhes do pedido
O sistema SHALL exibir em `OrderDetailModal` e `OrderDetailPage` os dados completos: cliente (nome, telefone, email), endereco de entrega formatado, itens (produto, quantidade, preco unitario, subtotal) em tabela, total, observacoes e `OrderTimeline`.

#### Scenario: Detalhes completos exibidos no modal
- **WHEN** o usuario clica em um card no Kanban
- **THEN** o modal exibe dados do cliente, endereco, itens e timeline

#### Scenario: Detalhes completos na pagina
- **WHEN** o usuario acessa `/orders/:id`
- **THEN** a pagina exibe todos os dados do pedido incluindo itens, endereco e timeline

### Requirement: Timeline de status do pedido
O sistema SHALL exibir um componente `OrderTimeline` como stepper vertical mostrando os passos do ciclo de vida. Passos anteriores ao status atual SHALL ter icone de check verde. Passo atual SHALL ter destaque visual. Passos futuros SHALL estar desabilitados (cinza).

#### Scenario: Timeline de pedido em preparo
- **WHEN** visualizar a timeline de um pedido com status PREPARING
- **THEN** PENDING e ACCEPTED aparecem como completados (check verde), PREPARING aparece como atual (destaque), READY e demais aparecem desabilitados

#### Scenario: Pedido cancelado
- **WHEN** visualizar a timeline de um pedido CANCELLED
- **THEN** os passos ate o ultimo status antes do cancelamento aparecem como completados e CANCELLED aparece com icone vermelho

### Requirement: Acoes condicionais por status
O sistema SHALL implementar `OrderActions` que renderiza botoes condicionais baseados no status atual:

- **PENDING**: "Aceitar" (primary) e "Recusar" (danger, abre RejectOrderModal)
- **ACCEPTED**: "Iniciar Preparo" (primary)
- **PREPARING**: "Pronto para Retirada" (primary)
- **READY**: "Saiu para Entrega" (primary)
- **OUT_FOR_DELIVERY**: "Finalizar Entrega" (primary)
- **DELIVERED/CANCELLED**: nenhum botao

#### Scenario: Aceitar pedido pendente
- **WHEN** o usuario clica em "Aceitar" em um pedido PENDING
- **THEN** `useAcceptOrder` e executado, toast de sucesso e exibido e o Kanban atualiza

#### Scenario: Recusar pedido com motivo
- **WHEN** o usuario clica em "Recusar" em um pedido PENDING
- **THEN** o `RejectOrderModal` abre com campo de motivo obrigatorio

#### Scenario: Transicao PREPARING para READY
- **WHEN** o usuario clica em "Pronto para Retirada" em um pedido PREPARING
- **THEN** `useUpdateOrderStatus` e chamado com `{ status: 'READY' }` e toast de sucesso e exibido

### Requirement: RejectOrderModal
O sistema SHALL implementar `RejectOrderModal` com campo de texto obrigatorio para motivo da recusa. Ao confirmar, SHALL chamar `useRejectOrder` com o motivo. O botao de confirmar SHALL exibir loading durante a mutation.

#### Scenario: Recusar com motivo valido
- **WHEN** o usuario digita "Sem ingredientes" e confirma
- **THEN** `PATCH /api/orders/{id}/reject` e chamado com `{ reason: "Sem ingredientes" }` e o modal fecha

#### Scenario: Motivo vazio
- **WHEN** o usuario tenta confirmar com motivo vazio
- **THEN** uma mensagem de erro e exibida e a requisicao NAO e enviada

### Requirement: Chat embutido no detalhe do pedido
O sistema SHALL exibir o `ChatPanel` (de `features/chat/components/ChatPanel.tsx`) embutido no `OrderDetailModal` e `OrderDetailPage`, substituindo o placeholder atual. O ChatPanel SHALL receber o `orderId` do pedido e conectar automaticamente ao canal WebSocket.

#### Scenario: Chat funcional no detalhe do pedido
- **WHEN** o usuario abre detalhes de um pedido
- **THEN** o ChatPanel e exibido com historico de mensagens e possibilidade de enviar novas mensagens em tempo real

#### Scenario: Chat no modal de detalhes
- **WHEN** o usuario abre o OrderDetailModal de um pedido
- **THEN** o ChatPanel e exibido abaixo da timeline com funcionalidade completa
