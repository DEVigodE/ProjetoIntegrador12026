# Order Management

Gerenciamento de pedidos com painel Kanban, ciclo de vida de status e acoes.

## Requirements

### Requirement: Painel Kanban de pedidos
O sistema SHALL exibir em `OrdersPage` um painel Kanban com colunas por status: PENDENTE, EM PREPARO, PRONTO, SAIU PARA ENTREGA. Cada card exibe numero do pedido, nome do cliente, valor total e tempo desde criacao.

#### Scenario: Kanban renderiza com colunas
- **WHEN** o usuario acessa `/orders`
- **THEN** quatro colunas sao exibidas com os pedidos agrupados por status

#### Scenario: Card clicavel
- **WHEN** o usuario clica em um card de pedido no Kanban
- **THEN** o `OrderDetailModal` abre com os detalhes completos do pedido

### Requirement: Lista de pedidos filtravel
O sistema SHALL exibir uma lista secundaria de todos os pedidos com paginacao e filtros por status e data.

#### Scenario: Filtrar por status
- **WHEN** o usuario seleciona status "CANCELLED" no filtro
- **THEN** apenas pedidos cancelados sao exibidos na lista

### Requirement: Detalhes do pedido
O sistema SHALL exibir em `OrderDetailPage` ou `OrderDetailModal` os dados completos: cliente (nome, telefone, email), endereco de entrega, itens (produto, quantidade, subtotal), total, observacoes e timeline de status.

#### Scenario: Detalhes completos exibidos
- **WHEN** o usuario acessa `/orders/:id`
- **THEN** todos os dados do pedido sao exibidos incluindo itens, endereco e timeline

### Requirement: Timeline de status do pedido
O sistema SHALL exibir um componente `OrderTimeline` mostrando o historico de transicoes de status com timestamps.

#### Scenario: Timeline de pedido entregue
- **WHEN** visualizar a timeline de um pedido com status DELIVERED
- **THEN** todos os passos sao exibidos: PENDING → ACCEPTED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED com timestamps

### Requirement: Acoes por status atual
O sistema SHALL exibir botoes de acao condicionais baseados no status atual do pedido:

- **PENDING**: "Aceitar" (`PATCH /api/orders/{id}/accept`) e "Recusar" (abre RejectOrderModal)
- **ACCEPTED**: "Iniciar Preparo" (`PATCH /api/orders/{id}/status` com body PREPARING)
- **PREPARING**: "Pronto para Retirada" (`PATCH /api/orders/{id}/status` com body READY)
- **READY**: "Saiu para Entrega" (abre AssignCourierModal se sem entregador)
- **OUT_FOR_DELIVERY**: "Finalizar Entrega" (`PATCH /api/orders/{id}/status` com body DELIVERED)

#### Scenario: Aceitar pedido pendente
- **WHEN** o usuario clica em "Aceitar" em um pedido PENDING
- **THEN** `PATCH /api/orders/{id}/accept` e chamado e o pedido muda para ACCEPTED

#### Scenario: Recusar pedido com motivo
- **WHEN** o usuario clica em "Recusar" em um pedido PENDING
- **THEN** o RejectOrderModal abre, o usuario digita o motivo, e `PATCH /api/orders/{id}/reject` e chamado com o motivo

#### Scenario: Transicao PREPARING → READY
- **WHEN** o usuario clica em "Pronto para Retirada" em um pedido PREPARING
- **THEN** o status e atualizado para READY

### Requirement: Chat embutido no detalhe do pedido
O sistema SHALL exibir o `ChatPanel` embutido na pagina/modal de detalhes do pedido, conectado ao canal WebSocket do pedido.

#### Scenario: Chat visivel no detalhe
- **WHEN** o usuario abre os detalhes de um pedido
- **THEN** o painel de chat e exibido com historico de mensagens e campo de envio

### Requirement: Enums de OrderStatus
O sistema SHALL usar os seguintes valores de enum (source of truth do backend Java):

`PENDING | ACCEPTED | PREPARING | READY | OUT_FOR_DELIVERY | DELIVERED | CANCELLED`

#### Scenario: Status mapeados corretamente
- **WHEN** o backend retorna um pedido com status "OUT_FOR_DELIVERY"
- **THEN** o frontend exibe o badge "Saiu para Entrega" (azul)

### Requirement: Hooks TanStack Query para pedidos
O sistema SHALL implementar os seguintes hooks:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useOrders` | GET | `/api/orders?status=&page=&size=` |
| `useActiveOrders` | GET | `/api/orders/active` |
| `useOrder` | GET | `/api/orders/{id}` |
| `useCreateOrder` | POST | `/api/orders` |
| `useAcceptOrder` | PATCH | `/api/orders/{id}/accept` |
| `useRejectOrder` | PATCH | `/api/orders/{id}/reject` |
| `useUpdateOrderStatus` | PATCH | `/api/orders/{id}/status` |

#### Scenario: Mutation invalida queries
- **WHEN** `useAcceptOrder` executa com sucesso
- **THEN** as queries `useOrders`, `useActiveOrders` e `useOrder` sao invalidadas

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
