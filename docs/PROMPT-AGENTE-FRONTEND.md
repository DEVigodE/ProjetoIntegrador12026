# Prompt para Agente AI — Criação do Frontend Web (React)

> Copie e cole tudo abaixo diretamente no agente AI.

---

## CONTEXTO DO PROJETO

Você é um engenheiro sênior React/TypeScript. Sua tarefa é criar **do zero** o frontend web completo de um sistema **Backoffice para Delivery de Alimentos**, seguindo rigorosamente a arquitetura e as decisões técnicas descritas abaixo.

O backend já existe e expõe APIs REST + WebSocket (STOMP). O frontend deve consumir exclusivamente essas APIs.

---

## 1. VISÃO GERAL

**Sistema**: Backoffice administrativo para restaurantes gerenciarem operações de delivery (produtos, pedidos, entregas, chat, relatórios).

**Tipo de aplicação**: SPA (Single Page Application) — somente para uso interno da equipe do restaurante (Admin, Operador, Despachante).

**Stack obrigatória**:

- React 18 + TypeScript 5
- Vite (bundler)
- TailwindCSS (estilização)
- React Router v6 (roteamento)
- TanStack Query v5 (cache + fetching de dados do servidor)
- Axios (cliente HTTP)
- Keycloak JS (`keycloak-js` + `@react-keycloak/web`) — autenticação OAuth2/OIDC
- SockJS-client + `@stomp/stompjs` (WebSocket/chat em tempo real)
- Zustand (estado global de UI — ex: notificações, alertas de pedido)
- React Hook Form + Zod (formulários com validação)
- Recharts (gráficos do dashboard e relatórios)
- React Toastify (notificações toast)
- date-fns (formatação de datas)

---

## 2. ESTRUTURA DO PROJETO

### Localização do projeto

```
backoffice-frontend/
```

### Criar com Vite

```bash
npm create vite@latest backoffice-frontend -- --template react-ts
cd backoffice-frontend
npm install
```

### Estrutura de pastas (seguir EXATAMENTE)

```
backoffice-frontend/
├── index.html
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── package.json
├── .env.example
│
└── src/
    ├── main.tsx                    # Ponto de entrada — provider de Keycloak
    ├── App.tsx                     # Roteamento principal
    ├── vite-env.d.ts
    │
    ├── config/
    │   ├── keycloak.ts             # Instância do Keycloak
    │   ├── axios.ts                # Instância Axios com interceptor JWT
    │   └── queryClient.ts         # Instância TanStack Query
    │
    ├── routes/
    │   ├── PrivateRoute.tsx        # Guard: redireciona para login se não autenticado
    │   └── RoleGuard.tsx           # Guard: bloqueia rota por role
    │
    ├── layouts/
    │   ├── MainLayout.tsx          # Layout com Sidebar + Header + Content
    │   └── AuthLayout.tsx          # Layout minimalista para loading de auth
    │
    ├── components/
    │   ├── ui/                     # Componentes genéricos reutilizáveis
    │   │   ├── Button.tsx
    │   │   ├── Input.tsx
    │   │   ├── Select.tsx
    │   │   ├── Modal.tsx
    │   │   ├── Badge.tsx
    │   │   ├── Spinner.tsx
    │   │   ├── Table.tsx
    │   │   ├── Pagination.tsx
    │   │   ├── ConfirmDialog.tsx
    │   │   └── EmptyState.tsx
    │   │
    │   ├── layout/
    │   │   ├── Sidebar.tsx         # Menu lateral com links por role
    │   │   ├── Header.tsx          # Barra superior com usuário, logout, notificações
    │   │   └── PageHeader.tsx      # Título + breadcrumb de cada página
    │   │
    │   └── shared/
    │       ├── StatusBadge.tsx     # Badge colorido por status de pedido/entrega
    │       ├── OrderCard.tsx       # Card compacto de pedido (usado no painel de pedidos)
    │       └── AudioAlert.tsx      # Emite som ao receber novo pedido
    │
    ├── features/
    │   │
    │   ├── dashboard/
    │   │   ├── pages/
    │   │   │   └── DashboardPage.tsx
    │   │   ├── components/
    │   │   │   ├── KpiCard.tsx             # Card de indicador (total pedidos, ticket médio...)
    │   │   │   ├── SalesChart.tsx          # Gráfico de vendas por período (Recharts)
    │   │   │   ├── TopProductsChart.tsx    # Gráfico de produtos mais vendidos
    │   │   │   └── ActiveOrdersList.tsx    # Lista de pedidos em andamento
    │   │   └── hooks/
    │   │       └── useDashboard.ts         # Integra GET /api/reports/dashboard
    │   │
    │   ├── catalog/
    │   │   ├── pages/
    │   │   │   ├── ProductListPage.tsx
    │   │   │   └── ProductFormPage.tsx
    │   │   ├── components/
    │   │   │   ├── ProductTable.tsx
    │   │   │   ├── ProductFilters.tsx
    │   │   │   ├── ProductForm.tsx
    │   │   │   ├── CategorySelect.tsx
    │   │   │   └── StockBadge.tsx
    │   │   ├── hooks/
    │   │   │   ├── useProducts.ts          # Listagem paginada (GET /api/products)
    │   │   │   ├── useProduct.ts           # Busca por ID
    │   │   │   ├── useCreateProduct.ts
    │   │   │   ├── useUpdateProduct.ts
    │   │   │   ├── useDeleteProduct.ts
    │   │   │   ├── useToggleAvailability.ts
    │   │   │   └── useCategories.ts        # GET /api/categories
    │   │   └── types/
    │   │       └── product.types.ts
    │   │
    │   ├── orders/
    │   │   ├── pages/
    │   │   │   ├── OrdersPage.tsx          # Painel em tempo real + lista de pedidos
    │   │   │   └── OrderDetailPage.tsx     # Detalhes completos do pedido
    │   │   ├── components/
    │   │   │   ├── OrdersPanel.tsx         # Colunas Kanban por status
    │   │   │   ├── OrderDetailModal.tsx    # Modal com detalhes + ações
    │   │   │   ├── OrderFilters.tsx
    │   │   │   ├── OrderTimeline.tsx       # Histórico de status do pedido
    │   │   │   └── RejectOrderModal.tsx    # Modal para recusar com motivo
    │   │   ├── hooks/
    │   │   │   ├── useOrders.ts            # GET /api/orders (paginado + filtros)
    │   │   │   ├── useActiveOrders.ts      # GET /api/orders/active
    │   │   │   ├── useOrder.ts             # GET /api/orders/{id}
    │   │   │   ├── useAcceptOrder.ts       # PATCH /api/orders/{id}/accept
    │   │   │   ├── useRejectOrder.ts       # PATCH /api/orders/{id}/reject
    │   │   │   └── useUpdateOrderStatus.ts # PATCH /api/orders/{id}/status
    │   │   └── types/
    │   │       └── order.types.ts
    │   │
    │   ├── delivery/
    │   │   ├── pages/
    │   │   │   ├── CouriersPage.tsx
    │   │   │   └── DeliveriesPage.tsx
    │   │   ├── components/
    │   │   │   ├── CourierTable.tsx
    │   │   │   ├── CourierForm.tsx
    │   │   │   ├── CourierStatusBadge.tsx
    │   │   │   ├── DeliveryTable.tsx
    │   │   │   └── AssignCourierModal.tsx  # Modal para atribuir entregador ao pedido
    │   │   ├── hooks/
    │   │   │   ├── useCouriers.ts          # GET /api/couriers
    │   │   │   ├── useAvailableCouriers.ts # GET /api/couriers/available
    │   │   │   ├── useCreateCourier.ts
    │   │   │   ├── useUpdateCourier.ts
    │   │   │   ├── useDeliveries.ts        # GET /api/deliveries/active
    │   │   │   ├── useCreateDelivery.ts
    │   │   │   └── useAssignCourier.ts     # PATCH /api/deliveries/{id}/assign
    │   │   └── types/
    │   │       └── delivery.types.ts
    │   │
    │   ├── chat/
    │   │   ├── components/
    │   │   │   ├── ChatPanel.tsx           # Painel de chat flutuante/embedded
    │   │   │   ├── MessageList.tsx
    │   │   │   ├── MessageInput.tsx
    │   │   │   └── MessageBubble.tsx
    │   │   ├── hooks/
    │   │   │   ├── useChat.ts              # GET /api/chat/{orderId}/messages
    │   │   │   └── useChatWebSocket.ts     # Conexão STOMP + subscribe + send
    │   │   └── types/
    │   │       └── chat.types.ts
    │   │
    │   ├── reports/
    │   │   ├── pages/
    │   │   │   └── ReportsPage.tsx
    │   │   ├── components/
    │   │   │   ├── SalesReportTable.tsx
    │   │   │   ├── TopSellingProducts.tsx
    │   │   │   ├── MetricsCards.tsx
    │   │   │   └── DateRangePicker.tsx
    │   │   └── hooks/
    │   │       ├── useSalesReport.ts       # GET /api/reports/sales
    │   │       ├── useTopSellingProducts.ts# GET /api/reports/products/top-selling
    │   │       └── useMetrics.ts           # GET /api/reports/metrics
    │   │
    │   └── settings/
    │       ├── pages/
    │       │   └── SettingsPage.tsx
    │       └── components/
    │           └── CategoryManager.tsx     # CRUD de categorias (Admin)
    │
    ├── store/
    │   ├── orderNotificationStore.ts   # Zustand: controla alertas de novos pedidos
    │   └── chatNotificationStore.ts    # Zustand: controla badge de mensagens não lidas
    │
    ├── services/
    │   └── websocket.ts                # Singleton do cliente STOMP global
    │
    └── utils/
        ├── formatCurrency.ts
        ├── formatDate.ts
        └── orderStatusLabel.ts         # Mapeia enum de status para rótulo PT-BR
```

---

## 3. AUTENTICAÇÃO — KEYCLOAK

### Dados do servidor Keycloak (desenvolvimento local)

```
URL:      http://localhost:8080
Realm:    delivery-backoffice
Client:   backoffice-frontend  (public client, PKCE habilitado)
```

### `src/config/keycloak.ts`

```ts
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: import.meta.env.VITE_KEYCLOAK_URL,
  realm: import.meta.env.VITE_KEYCLOAK_REALM,
  clientId: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
});

export default keycloak;
```

### `src/main.tsx` — Provider Keycloak

```tsx
import { ReactKeycloakProvider } from '@react-keycloak/web';
import keycloak from './config/keycloak';

root.render(
  <ReactKeycloakProvider
    authClient={keycloak}
    initOptions={{ onLoad: 'login-required', pkceMethod: 'S256' }}
    LoadingComponent={<AuthLoadingScreen />}
  >
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </ReactKeycloakProvider>
);
```

### Interceptor Axios com JWT

```ts
// src/config/axios.ts
import axios from 'axios';
import keycloak from './keycloak';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL, // http://localhost:8081
});

api.interceptors.request.use(async (config) => {
  if (keycloak.isTokenExpired(30)) {
    await keycloak.updateToken(30);
  }
  if (keycloak.token) {
    config.headers.Authorization = `Bearer ${keycloak.token}`;
  }
  return config;
});

export default api;
```

### Variáveis de ambiente (`.env.example`)

```env
VITE_API_BASE_URL=http://localhost:8081
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=delivery-backoffice
VITE_KEYCLOAK_CLIENT_ID=backoffice-frontend
VITE_WS_URL=http://localhost:8081/ws
```

---

## 4. CONTROLE DE ACESSO POR ROLE

### Roles disponíveis (extraídas do JWT — `realm_access.roles`)

| Role         | Permissões                                                   |
|--------------|--------------------------------------------------------------|
| `ADMIN`      | Acesso total: produtos, pedidos, entregas, relatórios, config|
| `OPERATOR`   | Produtos, pedidos (aceitar/recusar/atualizar status), chat   |
| `DISPATCHER` | Entregas, entregadores, atribuição de entregador, chat       |

### Hook `useRoles`

```ts
// Função auxiliar que lê realm_access.roles do token decodificado
export function useRoles(): string[] {
  const { keycloak } = useKeycloak();
  return keycloak.tokenParsed?.realm_access?.roles ?? [];
}

export function useHasRole(role: string): boolean {
  return useRoles().includes(role);
}
```

### `RoleGuard.tsx`

```tsx
// Renderiza children somente se usuário possui uma das roles exigidas
// Caso contrário, exibe mensagem de acesso negado ou redireciona
```

---

## 5. ROTEAMENTO (`src/App.tsx`)

```
/                          → redireciona para /dashboard
/dashboard                 → DashboardPage         (ADMIN, OPERATOR)
/products                  → ProductListPage        (ADMIN, OPERATOR)
/products/new              → ProductFormPage        (ADMIN, OPERATOR)
/products/:id/edit         → ProductFormPage        (ADMIN, OPERATOR)
/orders                    → OrdersPage             (ADMIN, OPERATOR)
/orders/:id                → OrderDetailPage        (ADMIN, OPERATOR)
/couriers                  → CouriersPage           (ADMIN, DISPATCHER)
/deliveries                → DeliveriesPage         (ADMIN, DISPATCHER)
/reports                   → ReportsPage            (ADMIN)
/settings                  → SettingsPage           (ADMIN)
```

Todas as rotas envolvidas em `<PrivateRoute>`. Rotas com role específica envolvidas em `<RoleGuard roles={[...]} />`.

---

## 6. CONSUMO DAS APIs REST

Use **TanStack Query** para todas as chamadas de leitura (GET) e **mutations** para escrita (POST/PUT/PATCH/DELETE). Invalide queries relacionadas após cada mutação bem-sucedida.

### Catalog

| Hook                    | Método | Endpoint                              |
|-------------------------|--------|---------------------------------------|
| `useProducts`           | GET    | `/api/products?page=0&size=20&...`    |
| `useProduct`            | GET    | `/api/products/{id}`                  |
| `useCreateProduct`      | POST   | `/api/products`                       |
| `useUpdateProduct`      | PUT    | `/api/products/{id}`                  |
| `useDeleteProduct`      | DELETE | `/api/products/{id}`                  |
| `useToggleAvailability` | PATCH  | `/api/products/{id}/availability`     |
| `useCategories`         | GET    | `/api/categories`                     |
| `useCreateCategory`     | POST   | `/api/categories`                     |

### Orders

| Hook                   | Método | Endpoint                          |
|------------------------|--------|-----------------------------------|
| `useOrders`            | GET    | `/api/orders?status=&page=&...`   |
| `useActiveOrders`      | GET    | `/api/orders/active`              |
| `useOrder`             | GET    | `/api/orders/{id}`                |
| `useCreateOrder`       | POST   | `/api/orders`                     |
| `useAcceptOrder`       | PATCH  | `/api/orders/{id}/accept`         |
| `useRejectOrder`       | PATCH  | `/api/orders/{id}/reject`         |
| `useUpdateOrderStatus` | PATCH  | `/api/orders/{id}/status`         |

### Delivery

| Hook                   | Método | Endpoint                          |
|------------------------|--------|-----------------------------------|
| `useCouriers`          | GET    | `/api/couriers`                   |
| `useAvailableCouriers` | GET    | `/api/couriers/available`         |
| `useCreateCourier`     | POST   | `/api/couriers`                   |
| `useUpdateCourier`     | PUT    | `/api/couriers/{id}`              |
| `useDeliveries`        | GET    | `/api/deliveries/active`          |
| `useCreateDelivery`    | POST   | `/api/deliveries`                 |
| `useAssignCourier`     | PATCH  | `/api/deliveries/{id}/assign`     |

### Chat (REST — histórico)

| Hook       | Método | Endpoint                        |
|------------|--------|---------------------------------|
| `useChat`  | GET    | `/api/chat/{orderId}/messages`  |

### Reports

| Hook                    | Método | Endpoint                              |
|-------------------------|--------|---------------------------------------|
| `useSalesReport`        | GET    | `/api/reports/sales?from=&to=`        |
| `useTopSellingProducts` | GET    | `/api/reports/products/top-selling`   |
| `useMetrics`            | GET    | `/api/reports/metrics`                |
| `useDashboard`          | GET    | `/api/reports/dashboard`              |

---

## 7. WEBSOCKET — CHAT EM TEMPO REAL

### Configuração do cliente STOMP

```ts
// src/services/websocket.ts
import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';
import keycloak from '../config/keycloak';

let stompClient: Client | null = null;

export function getStompClient(): Client {
  if (!stompClient) {
    stompClient = new Client({
      webSocketFactory: () =>
        new SockJS(`${import.meta.env.VITE_WS_URL}?token=${keycloak.token}`),
      reconnectDelay: 5000,
    });
  }
  return stompClient;
}
```

### Hook `useChatWebSocket`

```ts
// src/features/chat/hooks/useChatWebSocket.ts
// - Ativa o cliente STOMP na montagem (client.activate())
// - Subscreve /topic/chat/{orderId}
// - Ao receber nova mensagem, adiciona ao estado local
// - Expõe função sendMessage() que publica em /app/chat/{orderId}/send
// - Desconecta na desmontagem
```

### Estrutura da mensagem recebida via WebSocket

```ts
interface MessageResponse {
  id: number;
  orderId: number;
  senderId: string;
  senderType: 'STORE' | 'CUSTOMER' | 'COURIER' | 'SYSTEM';
  content: string;
  sentAt: string; // ISO 8601
  readAt: string | null;
}
```

---

## 8. NOTIFICAÇÕES EM TEMPO REAL DE PEDIDOS

O painel de pedidos deve atualizar automaticamente usando **polling a cada 10s** com TanStack Query (`refetchInterval: 10000`) na query `useActiveOrders`. Quando um novo pedido chega (comparando o array retornado), o sistema deve:

1. Disparar um **toast** visual (React Toastify, posição top-right)
2. Reproduzir um **som de alerta** (`AudioAlert.tsx`) usando a Web Audio API
3. Atualizar o **badge numérico** no item do menu "Pedidos" via Zustand (`orderNotificationStore`)

### `src/store/orderNotificationStore.ts`

```ts
import { create } from 'zustand';

interface OrderNotificationStore {
  pendingCount: number;
  setPendingCount: (count: number) => void;
  increment: () => void;
  clear: () => void;
}

export const useOrderNotificationStore = create<OrderNotificationStore>((set) => ({
  pendingCount: 0,
  setPendingCount: (count) => set({ pendingCount: count }),
  increment: () => set((s) => ({ pendingCount: s.pendingCount + 1 })),
  clear: () => set({ pendingCount: 0 }),
}));
```

---

## 9. LAYOUT PRINCIPAL

### `MainLayout.tsx`

```
┌─────────────────────────────────────────────────────────┐
│  HEADER: Logo | Título da página | Notificações | Usuário│
├──────────────┬──────────────────────────────────────────┤
│              │                                          │
│   SIDEBAR    │           CONTENT AREA                  │
│              │                                          │
│  Dashboard   │   <Outlet /> (React Router)              │
│  Pedidos 🔴  │                                          │
│  Produtos    │                                          │
│  Entregas    │                                          │
│  Relatórios  │                                          │
│  Config ⚙️   │                                          │
│              │                                          │
│  [Sair]      │                                          │
└──────────────┴──────────────────────────────────────────┘
```

- O item **Pedidos** exibe badge vermelho com `pendingCount` do `orderNotificationStore`
- Itens do menu são ocultados de acordo com a role do usuário
- O Header exibe nome do usuário (`keycloak.tokenParsed?.name`) e botão de logout (`keycloak.logout()`)

---

## 10. PÁGINAS E FUNCIONALIDADES (detalhe)

### 10.1 `DashboardPage`

- KPI Cards: Total de pedidos hoje, Ticket médio, Pedidos em andamento, Entregadores ativos
- Gráfico de barras: Vendas dos últimos 7 dias (Recharts `BarChart`)
- Gráfico de pizza: Top 5 produtos mais vendidos (Recharts `PieChart`)
- Lista de pedidos ativos em andamento (resumo, clicável para abrir detalhes)
- Dados via `GET /api/reports/dashboard` + `GET /api/orders/active`

### 10.2 `ProductListPage`

- Tabela paginada com: Nome, Categoria, Preço, Estoque, Status (ativo/inativo), Ações
- Filtros por nome/categoria/disponibilidade
- Botão toggle disponibilidade inline (PATCH `/availability`)
- Soft delete com `ConfirmDialog`
- Botão "Novo Produto" → navega para `ProductFormPage`
- Alerta visual (Badge vermelho) em produtos com estoque abaixo do mínimo

### 10.3 `ProductFormPage` (criação e edição)

- Campos: nome, descrição, preço, categoria (select), URL da imagem, estoque atual, estoque mínimo
- Validação com Zod via React Hook Form
- Ao editar, carrega os dados atuais do produto
- Submit chama `useCreateProduct` ou `useUpdateProduct` conforme o caso

### 10.4 `OrdersPage`

- **Painel Kanban** com colunas por status: `PENDENTE | EM PREPARO | PRONTO | SAIU PARA ENTREGA`
- Cada card exibe: número do pedido, nome do cliente, valor total, tempo desde criação
- Clique no card abre `OrderDetailModal`
- Lista secundária filtrável (todos os pedidos, com paginação e filtros por status e data)
- Atualização automática via polling (`refetchInterval: 10_000`)
- Som + toast ao detectar novo pedido `PENDING`

### 10.5 `OrderDetailPage` / `OrderDetailModal`

- Dados completos: cliente, endereco, itens (produto, qtd, subtotal), total, observações
- Timeline do pedido: histórico de status com timestamp
- Ações por status atual:
  - `PENDING` → Botões "Aceitar" e "Recusar" (recusa abre `RejectOrderModal` para justificativa)
  - `ACCEPTED` → Botão "Iniciar Preparo"
  - `PREPARING` → Botão "Pronto para Retirada"
  - `READY` → Botão "Saiu para Entrega" (abre `AssignCourierModal` se entregador não atribuído)
  - `OUT_FOR_DELIVERY` → Botão "Finalizar Entrega"
- Painel de chat embutido (`ChatPanel`) com o canal WebSocket do pedido

### 10.6 `CouriersPage`

- Tabela de entregadores: Nome, Telefone, Veículo, Status (AVAILABLE/IN_DELIVERY/OFFLINE), Ativo
- Modal de cadastro/edição com `CourierForm`
- Toggle de status ativo/inativo

### 10.7 `DeliveriesPage`

- Tabela de entregas em andamento: Pedido, Entregador, Status, Atribuído em
- Botão para atribuir/reatribuir entregador (`AssignCourierModal`)

### 10.8 `ReportsPage`

- `DateRangePicker` para selecionar período
- Tabela de relatório de vendas por dia
- Gráfico de linha: Evolução de pedidos no período (Recharts `LineChart`)
- Cards de métricas: Total de pedidos, total faturado, ticket médio, taxa de aceitação
- Lista de top produtos mais vendidos

### 10.9 `SettingsPage`

- Gerenciamento de categorias: listar, criar, editar nome
- (Somente `ADMIN`)

---

## 11. TIPOS TYPESCRIPT (exemplos obrigatórios)

### `order.types.ts`

```ts
export type OrderStatus =
  | 'PENDING'
  | 'ACCEPTED'
  | 'PREPARING'
  | 'READY'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'CANCELLED';

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  unitPrice: number;
  quantity: number;
  subtotal: number;
  notes?: string;
}

export interface Order {
  id: number;
  status: OrderStatus;
  customerName: string;
  customerPhone: string;
  customerEmail?: string;
  deliveryStreet: string;
  deliveryNumber: string;
  deliveryComplement?: string;
  deliveryNeighborhood: string;
  deliveryCity: string;
  deliveryState: string;
  deliveryZipCode: string;
  totalAmount: number;
  notes?: string;
  rejectedReason?: string;
  items: OrderItem[];
  createdAt: string;
  updatedAt: string;
}
```

### `product.types.ts`

```ts
export interface Product {
  id: number;
  name: string;
  description?: string;
  price: number;
  imageUrl?: string;
  available: boolean;
  stockQuantity: number;
  minStockAlert: number;
  category: Category;
  deletedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: number;
  name: string;
  description?: string;
  active: boolean;
}
```

### `delivery.types.ts`

```ts
export type CourierStatus = 'AVAILABLE' | 'IN_DELIVERY' | 'OFFLINE';
export type DeliveryStatus = 'PENDING' | 'ASSIGNED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';

export interface Courier {
  id: number;
  name: string;
  phone: string;
  email?: string;
  vehicleType?: string;
  vehiclePlate?: string;
  status: CourierStatus;
  active: boolean;
}

export interface Delivery {
  id: number;
  orderId: number;
  courier?: Courier;
  status: DeliveryStatus;
  assignedAt?: string;
  pickedUpAt?: string;
  deliveredAt?: string;
  createdAt: string;
}
```

---

## 12. ESTILIZAÇÃO — TAILWINDCSS

**Configuração do tema** (`tailwind.config.ts`):

```ts
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          500: '#f97316', // laranja — cor principal da marca
          600: '#ea580c',
        },
        sidebar: '#1e293b',  // slate-800
      },
    },
  },
};
```

**Convenções de estilo**:
- Sidebar: fundo `slate-800`, texto branco, item ativo com `primary-500`
- Header: fundo branco, sombra suave
- Cards KPI: fundo branco, borda arredondada, sombra `shadow-md`
- Status badges: verde para ativo/aceito, amarelo para em preparo, azul para saiu para entrega, vermelho para cancelado/recusado
- Botão primário: `bg-primary-500 text-white hover:bg-primary-600`
- Toda a tipografia em português do Brasil

---

## 13. `package.json` — DEPENDÊNCIAS

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.2",
    "@tanstack/react-query": "^5.56.2",
    "axios": "^1.7.7",
    "keycloak-js": "^24.0.5",
    "@react-keycloak/web": "^3.4.0",
    "@stomp/stompjs": "^7.0.0",
    "sockjs-client": "^1.6.1",
    "zustand": "^4.5.5",
    "react-hook-form": "^7.53.0",
    "zod": "^3.23.8",
    "@hookform/resolvers": "^3.9.0",
    "recharts": "^2.12.7",
    "react-toastify": "^10.0.5",
    "date-fns": "^3.6.0",
    "tailwindcss": "^3.4.11",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.47"
  },
  "devDependencies": {
    "@types/react": "^18.3.5",
    "@types/react-dom": "^18.3.0",
    "@types/sockjs-client": "^1.5.4",
    "@vitejs/plugin-react": "^4.3.1",
    "typescript": "^5.5.3",
    "vite": "^5.4.6"
  }
}
```

---

## 14. ORDEM DE IMPLEMENTAÇÃO SUGERIDA

Implemente nesta ordem para garantir que as dependências estejam disponíveis quando cada feature for desenvolvida:

1. **Boilerplate**: Vite + TypeScript + TailwindCSS + ESLint configurados
2. **Autenticação**: Keycloak + Axios interceptor + variáveis de ambiente
3. **Layout base**: `MainLayout`, `Sidebar`, `Header`, `PrivateRoute`, `RoleGuard`
4. **Componentes UI**: Button, Input, Select, Modal, Badge, Spinner, Table, Pagination
5. **Dashboard**: `DashboardPage` com KPIs e gráficos
6. **Catálogo**: `ProductListPage` + `ProductFormPage` + hooks + types
7. **Pedidos**: `OrdersPage` + `OrderDetailModal` + polling + notificações
8. **Entregas**: `CouriersPage` + `DeliveriesPage` + `AssignCourierModal`
9. **Chat**: `ChatPanel` + `useChatWebSocket` + `chatNotificationStore`
10. **Relatórios**: `ReportsPage` com gráficos e filtros de data
11. **Configurações**: `SettingsPage` com gerenciamento de categorias

---

## 15. RESTRIÇÕES E OBSERVAÇÕES IMPORTANTES

1. **Não criar backend próprio** — apenas consumir as APIs do backend Spring Boot existente
2. **Não usar Redux** — preferir TanStack Query para server state e Zustand somente para UI state
3. **Não usar classe CSS global além do Tailwind** — usar apenas classes utilitárias
4. **Todos os textos da interface em português do Brasil**
5. **Sempre tipar com TypeScript** — proibido usar `any`
6. **Tratar erros de API**: exibir mensagem de erro amigável ao usuário via toast quando requisição falhar
7. **Tokens JWT**: nunca armazenar em localStorage — o Keycloak JS gerencia o token em memória
8. **CORS**: o backend já está configurado para aceitar requisições de `http://localhost:5173`
9. **Acessibilidade mínima**: usar `aria-label` em botões de ícone, foco visível nos inputs
10. **Responsividade**: design otimizado para desktop (1280px+), com suporte mínimo a 1024px

---

## 16. RESULTADO ESPERADO

Ao final da implementação, o agente deve ter criado:

- [ ] Projeto Vite + React + TypeScript funcional
- [ ] Autenticação completa via Keycloak (login, logout, refresh automático, PKCE)
- [ ] Layout principal com sidebar, header e rotas protegidas por role
- [ ] 9 páginas funcionais consumindo as APIs do backend
- [ ] Painel de pedidos com atualização automática, som e toast de alerta
- [ ] Chat em tempo real via WebSocket/STOMP embutido nos detalhes do pedido
- [ ] Gráficos de relatórios com Recharts
- [ ] Todos os componentes tipados com TypeScript
- [ ] `.env.example` com todas as variáveis necessárias
- [ ] `README.md` com instruções de setup e execução local
