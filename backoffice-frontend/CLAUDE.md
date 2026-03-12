# CLAUDE.md - Delivery Backoffice Frontend

## 1. Visao Geral

SPA React para o backoffice de um sistema de Delivery de Alimentos. Consome exclusivamente as APIs REST e WebSocket do backend Spring Boot (`backoffice-backend/`). Uso interno da equipe do restaurante (Admin, Operador, Despachante).

Projeto academico do Projeto Integrador 2026 — mesma base do backend.

## 2. Stack

| Tecnologia | Versao | Uso |
|---|---|---|
| React | 18 | UI library |
| TypeScript | 5 | Tipagem estatica |
| Vite | 5 | Bundler + dev server |
| TailwindCSS | 3 | Estilizacao (classes utilitarias) |
| React Router | v6 | Roteamento SPA |
| TanStack Query | v5 | Server state (cache + fetching) |
| Axios | 1.7+ | Cliente HTTP com interceptor JWT |
| keycloak-js | 24+ | Autenticacao OAuth2/OIDC |
| @react-keycloak/web | 3.4 | Provider React para Keycloak |
| @stomp/stompjs | 7 | WebSocket/STOMP (chat tempo real) |
| sockjs-client | 1.6 | Fallback WebSocket |
| Zustand | 4.5 | Estado global de UI (notificacoes) |
| React Hook Form | 7.53 | Formularios |
| Zod | 3.23 | Validacao de schemas |
| @hookform/resolvers | 3.9 | Integracao RHF + Zod |
| Recharts | 2.12 | Graficos (dashboard, relatorios) |
| React Toastify | 10 | Notificacoes toast |
| date-fns | 3.6 | Formatacao de datas |

## 3. Como Rodar

```bash
# 1. Criar projeto (apenas na primeira vez)
npm create vite@latest backoffice-frontend -- --template react-ts
cd backoffice-frontend
npm install

# 2. Instalar dependencias
npm install react-router-dom @tanstack/react-query axios keycloak-js @react-keycloak/web \
  @stomp/stompjs sockjs-client zustand react-hook-form zod @hookform/resolvers \
  recharts react-toastify date-fns

npm install -D tailwindcss postcss autoprefixer @types/sockjs-client

# 3. Copiar .env.example para .env e ajustar se necessario
cp .env.example .env

# 4. Subir infraestrutura (na pasta backoffice-backend/)
cd ../backoffice-backend && docker-compose up -d

# 5. Rodar backend (na pasta backoffice-backend/)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 6. Rodar frontend (na pasta backoffice-frontend/)
cd ../backoffice-frontend && npm run dev
```

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8081
- **Swagger UI**: http://localhost:8081/swagger-ui.html
- **Keycloak Admin**: http://localhost:8080 (admin/admin)

**IMPORTANTE**: O Vite DEVE rodar na porta 3000 (configurar em `vite.config.ts`) pois o Keycloak so tem redirect URIs para `localhost:3000` e `localhost:8081`.

## 4. Variaveis de Ambiente

Arquivo `.env.example`:

```env
VITE_API_BASE_URL=http://localhost:8081
VITE_KEYCLOAK_URL=http://localhost:8080
VITE_KEYCLOAK_REALM=delivery-backoffice
VITE_KEYCLOAK_CLIENT_ID=backoffice-webapp
VITE_WS_URL=http://localhost:8081/ws
```

**Valores corretos** (extraidos do `keycloak/delivery-backoffice-realm.json`):
- Realm: `delivery-backoffice`
- Client ID: `backoffice-webapp` (public client, PKCE habilitado)
- NAO usar `backoffice-frontend` — o client correto no Keycloak eh `backoffice-webapp`

## 5. Estrutura de Pastas

```
backoffice-frontend/
├── index.html
├── vite.config.ts              # Configurar port: 3000
├── tailwind.config.ts
├── tsconfig.json
├── package.json
├── .env.example
│
└── src/
    ├── main.tsx                    # Ponto de entrada — provider Keycloak
    ├── App.tsx                     # Roteamento principal
    ├── vite-env.d.ts
    │
    ├── config/
    │   ├── keycloak.ts             # Instancia do Keycloak
    │   ├── axios.ts                # Instancia Axios com interceptor JWT
    │   └── queryClient.ts          # Instancia TanStack Query
    │
    ├── routes/
    │   ├── PrivateRoute.tsx        # Guard: redireciona se nao autenticado
    │   └── RoleGuard.tsx           # Guard: bloqueia rota por role
    │
    ├── layouts/
    │   ├── MainLayout.tsx          # Sidebar + Header + Content
    │   └── AuthLayout.tsx          # Loading de auth
    │
    ├── components/
    │   ├── ui/                     # Componentes genericos reutilizaveis
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
    │   │   ├── Header.tsx          # Barra superior com usuario, logout, notificacoes
    │   │   └── PageHeader.tsx      # Titulo + breadcrumb
    │   │
    │   └── shared/
    │       ├── StatusBadge.tsx     # Badge colorido por status
    │       ├── OrderCard.tsx       # Card compacto de pedido
    │       └── AudioAlert.tsx      # Som de alerta (Web Audio API)
    │
    ├── features/
    │   ├── dashboard/
    │   │   ├── pages/DashboardPage.tsx
    │   │   ├── components/
    │   │   │   ├── KpiCard.tsx
    │   │   │   ├── SalesChart.tsx          # Recharts BarChart
    │   │   │   ├── TopProductsChart.tsx    # Recharts PieChart
    │   │   │   └── ActiveOrdersList.tsx
    │   │   └── hooks/useDashboard.ts       # GET /api/reports/dashboard
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
    │   │   │   ├── useProducts.ts           # GET /api/products
    │   │   │   ├── useProduct.ts            # GET /api/products/{id}
    │   │   │   ├── useCreateProduct.ts      # POST /api/products
    │   │   │   ├── useUpdateProduct.ts      # PUT /api/products/{id}
    │   │   │   ├── useDeleteProduct.ts      # DELETE /api/products/{id}
    │   │   │   ├── useToggleAvailability.ts # PATCH /api/products/{id}/availability
    │   │   │   └── useCategories.ts         # GET /api/categories
    │   │   └── types/product.types.ts
    │   │
    │   ├── orders/
    │   │   ├── pages/
    │   │   │   ├── OrdersPage.tsx           # Painel Kanban + lista
    │   │   │   └── OrderDetailPage.tsx
    │   │   ├── components/
    │   │   │   ├── OrdersPanel.tsx          # Colunas Kanban por status
    │   │   │   ├── OrderDetailModal.tsx
    │   │   │   ├── OrderFilters.tsx
    │   │   │   ├── OrderTimeline.tsx        # Historico de status
    │   │   │   └── RejectOrderModal.tsx     # Modal para recusar com motivo
    │   │   ├── hooks/
    │   │   │   ├── useOrders.ts             # GET /api/orders
    │   │   │   ├── useActiveOrders.ts       # GET /api/orders/active
    │   │   │   ├── useOrder.ts              # GET /api/orders/{id}
    │   │   │   ├── useAcceptOrder.ts        # PATCH /api/orders/{id}/accept
    │   │   │   ├── useRejectOrder.ts        # PATCH /api/orders/{id}/reject
    │   │   │   └── useUpdateOrderStatus.ts  # PATCH /api/orders/{id}/status
    │   │   └── types/order.types.ts
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
    │   │   │   └── AssignCourierModal.tsx
    │   │   ├── hooks/
    │   │   │   ├── useCouriers.ts           # GET /api/couriers
    │   │   │   ├── useAvailableCouriers.ts  # GET /api/couriers/available
    │   │   │   ├── useCreateCourier.ts      # POST /api/couriers
    │   │   │   ├── useUpdateCourier.ts      # PUT /api/couriers/{id}
    │   │   │   ├── useDeliveries.ts         # GET /api/deliveries/active
    │   │   │   ├── useCreateDelivery.ts     # POST /api/deliveries
    │   │   │   └── useAssignCourier.ts      # PATCH /api/deliveries/{id}/assign
    │   │   └── types/delivery.types.ts
    │   │
    │   ├── chat/
    │   │   ├── components/
    │   │   │   ├── ChatPanel.tsx
    │   │   │   ├── MessageList.tsx
    │   │   │   ├── MessageInput.tsx
    │   │   │   └── MessageBubble.tsx
    │   │   ├── hooks/
    │   │   │   ├── useChat.ts               # GET /api/chat/{orderId}/messages
    │   │   │   └── useChatWebSocket.ts      # STOMP subscribe + send
    │   │   └── types/chat.types.ts
    │   │
    │   ├── reports/
    │   │   ├── pages/ReportsPage.tsx
    │   │   ├── components/
    │   │   │   ├── SalesReportTable.tsx
    │   │   │   ├── TopSellingProducts.tsx
    │   │   │   ├── MetricsCards.tsx
    │   │   │   └── DateRangePicker.tsx
    │   │   └── hooks/
    │   │       ├── useSalesReport.ts        # GET /api/reports/sales
    │   │       ├── useTopSellingProducts.ts  # GET /api/reports/products/top-selling
    │   │       └── useMetrics.ts            # GET /api/reports/metrics
    │   │
    │   └── settings/
    │       ├── pages/SettingsPage.tsx
    │       └── components/CategoryManager.tsx   # CRUD categorias (ADMIN)
    │
    ├── store/
    │   ├── orderNotificationStore.ts    # Zustand: alertas de novos pedidos
    │   └── chatNotificationStore.ts     # Zustand: badge mensagens nao lidas
    │
    ├── services/
    │   └── websocket.ts                 # Singleton STOMP client
    │
    └── utils/
        ├── formatCurrency.ts
        ├── formatDate.ts
        └── orderStatusLabel.ts          # Enum status -> rotulo PT-BR
```

## 6. Autenticacao (Keycloak)

### Configuracao do Keycloak (`src/config/keycloak.ts`)

```ts
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: import.meta.env.VITE_KEYCLOAK_URL,      // http://localhost:8080
  realm: import.meta.env.VITE_KEYCLOAK_REALM,   // delivery-backoffice
  clientId: import.meta.env.VITE_KEYCLOAK_CLIENT_ID, // backoffice-webapp
});

export default keycloak;
```

### Provider no `main.tsx`

```tsx
<ReactKeycloakProvider
  authClient={keycloak}
  initOptions={{ onLoad: 'login-required', pkceMethod: 'S256' }}
  LoadingComponent={<AuthLoadingScreen />}
>
  <QueryClientProvider client={queryClient}>
    <App />
  </QueryClientProvider>
</ReactKeycloakProvider>
```

### Interceptor Axios com JWT (`src/config/axios.ts`)

```ts
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

### Dados do Keycloak (realm JSON importado automaticamente)

- **Realm**: `delivery-backoffice`
- **Client frontend**: `backoffice-webapp` (public, Authorization Code + PKCE)
- **Client backend**: `backoffice-api` (bearer-only)
- **Redirect URIs**: `http://localhost:3000/*`, `http://localhost:8081/*`
- **Import automatico**: docker-compose usa `--import-realm` com volume `./keycloak/`

## 7. Controle de Acesso (Roles)

Roles extraidas do JWT via `realm_access.roles`:

| Role | Permissoes |
|---|---|
| `ADMIN` | Acesso total: dashboard, produtos, pedidos, entregas, relatorios, configuracoes |
| `OPERATOR` | Dashboard, produtos (CRUD), pedidos (aceitar/recusar/atualizar status), chat |
| `DISPATCHER` | Entregas, entregadores (CRUD), atribuicao de entregador, chat |

### Usuarios de Teste (do `delivery-backoffice-realm.json`)

| Usuario | Senha | Role | Email |
|---|---|---|---|
| `admin` | `admin123` | ADMIN | admin@delivery.dev |
| `operador` | `operador123` | OPERATOR | operador@delivery.dev |
| `despachante` | `despachante123` | DISPATCHER | despachante@delivery.dev |

### Hook `useRoles`

```ts
export function useRoles(): string[] {
  const { keycloak } = useKeycloak();
  return keycloak.tokenParsed?.realm_access?.roles ?? [];
}

export function useHasRole(role: string): boolean {
  return useRoles().includes(role);
}
```

### `RoleGuard.tsx`

Renderiza children somente se usuario possui uma das roles exigidas. Caso contrario, redireciona ou exibe mensagem de acesso negado.

## 8. Roteamento (`src/App.tsx`)

| Rota | Pagina | Roles |
|---|---|---|
| `/` | Redireciona para `/dashboard` | - |
| `/dashboard` | DashboardPage | ADMIN, OPERATOR |
| `/products` | ProductListPage | ADMIN, OPERATOR |
| `/products/new` | ProductFormPage | ADMIN, OPERATOR |
| `/products/:id/edit` | ProductFormPage | ADMIN, OPERATOR |
| `/orders` | OrdersPage | ADMIN, OPERATOR |
| `/orders/:id` | OrderDetailPage | ADMIN, OPERATOR |
| `/couriers` | CouriersPage | ADMIN, DISPATCHER |
| `/deliveries` | DeliveriesPage | ADMIN, DISPATCHER |
| `/reports` | ReportsPage | ADMIN |
| `/settings` | SettingsPage | ADMIN |

Todas as rotas envolvidas em `<PrivateRoute>`. Rotas com role especifica envolvidas em `<RoleGuard roles={[...]} />`.

## 9. Consumo das APIs REST

Usar **TanStack Query** para leitura (GET) e **mutations** para escrita (POST/PUT/PATCH/DELETE). Invalidar queries relacionadas apos cada mutacao bem-sucedida.

### Catalog

| Hook | Metodo | Endpoint |
|---|---|---|
| `useProducts` | GET | `/api/products?page=0&size=20&...` |
| `useProduct` | GET | `/api/products/{id}` |
| `useCreateProduct` | POST | `/api/products` |
| `useUpdateProduct` | PUT | `/api/products/{id}` |
| `useDeleteProduct` | DELETE | `/api/products/{id}` |
| `useToggleAvailability` | PATCH | `/api/products/{id}/availability` |
| `useCategories` | GET | `/api/categories` |
| `useCreateCategory` | POST | `/api/categories` |

### Orders

| Hook | Metodo | Endpoint |
|---|---|---|
| `useOrders` | GET | `/api/orders?status=&page=&size=` |
| `useActiveOrders` | GET | `/api/orders/active` |
| `useOrder` | GET | `/api/orders/{id}` |
| `useCreateOrder` | POST | `/api/orders` |
| `useAcceptOrder` | PATCH | `/api/orders/{id}/accept` |
| `useRejectOrder` | PATCH | `/api/orders/{id}/reject` |
| `useUpdateOrderStatus` | PATCH | `/api/orders/{id}/status` |

### Delivery

| Hook | Metodo | Endpoint |
|---|---|---|
| `useCouriers` | GET | `/api/couriers` |
| `useAvailableCouriers` | GET | `/api/couriers/available` |
| `useCreateCourier` | POST | `/api/couriers` |
| `useUpdateCourier` | PUT | `/api/couriers/{id}` |
| `useDeliveries` | GET | `/api/deliveries/active` |
| `useCreateDelivery` | POST | `/api/deliveries` |
| `useAssignCourier` | PATCH | `/api/deliveries/{id}/assign` |

### Chat (REST — historico)

| Hook | Metodo | Endpoint |
|---|---|---|
| `useChat` | GET | `/api/chat/{orderId}/messages` |
| `useChatChannel` | GET | `/api/chat/{orderId}` |

### Reports

| Hook | Metodo | Endpoint |
|---|---|---|
| `useDashboard` | GET | `/api/reports/dashboard` |
| `useSalesReport` | GET | `/api/reports/sales?startDate=&endDate=` |
| `useTopSellingProducts` | GET | `/api/reports/products/top-selling` |
| `useMetrics` | GET | `/api/reports/metrics` |

## 10. WebSocket/STOMP — Chat em Tempo Real

### Configuracao (`src/services/websocket.ts`)

```ts
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

- Ativa o client STOMP na montagem (`client.activate()`)
- Subscribe em `/topic/chat/{orderId}`
- Envia mensagens via `/app/chat/{orderId}/send`
- Desconecta na desmontagem

### Endpoint WebSocket do Backend

- **Conectar**: `ws://localhost:8081/ws` (com SockJS fallback)
- **Enviar**: `/app/chat/{orderId}/send`
- **Receber**: subscribe `/topic/chat/{orderId}`

## 11. Notificacoes de Pedidos

O painel de pedidos atualiza automaticamente via **polling a cada 10s** com TanStack Query (`refetchInterval: 10_000`) no `useActiveOrders`.

Quando um novo pedido PENDING chega:
1. **Toast** visual (React Toastify, posicao top-right)
2. **Som de alerta** (`AudioAlert.tsx` com Web Audio API)
3. **Badge numerico** no menu "Pedidos" via Zustand (`orderNotificationStore`)

### `orderNotificationStore.ts`

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

## 12. Layout e Estilizacao

### Tema TailwindCSS (`tailwind.config.ts`)

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
        sidebar: '#1e293b', // slate-800
      },
    },
  },
};
```

### Convencoes Visuais

- **Sidebar**: fundo `slate-800`, texto branco, item ativo com `primary-500`
- **Header**: fundo branco, sombra suave
- **Cards KPI**: fundo branco, borda arredondada, `shadow-md`
- **Status badges**: verde (ativo/aceito), amarelo (em preparo), azul (saiu entrega), vermelho (cancelado)
- **Botao primario**: `bg-primary-500 text-white hover:bg-primary-600`
- **Tipografia**: toda em portugues do Brasil
- **Responsividade**: otimizado para desktop (1280px+), suporte minimo a 1024px

### Layout Principal (`MainLayout.tsx`)

```
┌──────────────────────────────────────────────────────┐
│  HEADER: Logo | Titulo da pagina | Notificacoes | User│
├──────────────┬───────────────────────────────────────┤
│              │                                       │
│   SIDEBAR    │           CONTENT AREA                │
│              │                                       │
│  Dashboard   │   <Outlet /> (React Router)           │
│  Pedidos [3] │                                       │
│  Produtos    │                                       │
│  Entregas    │                                       │
│  Relatorios  │                                       │
│  Config      │                                       │
│              │                                       │
│  [Sair]      │                                       │
└──────────────┴───────────────────────────────────────┘
```

- Item "Pedidos" exibe badge com `pendingCount` do `orderNotificationStore`
- Itens do menu ocultados de acordo com a role do usuario
- Header exibe nome do usuario (`keycloak.tokenParsed?.name`) e botao de logout

## 13. Tipos TypeScript

**IMPORTANTE**: Os tipos abaixo espelham os enums REAIS do backend Java (source of truth). O `docs/PROMPT-AGENTE-FRONTEND.md` tem valores incorretos em alguns enums — use SEMPRE os valores abaixo.

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

**ATENCAO — Enums corrigidos (backend eh source of truth)**:

```ts
// CORRETO: backend usa BUSY (NAO "IN_DELIVERY" como diz o PROMPT)
export type CourierStatus = 'AVAILABLE' | 'BUSY' | 'OFFLINE';

// CORRETO: backend tem apenas 4 valores (NAO "IN_PROGRESS"/"COMPLETED"/"CANCELLED")
export type DeliveryStatus = 'PENDING' | 'ASSIGNED' | 'PICKED_UP' | 'DELIVERED';

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

### `chat.types.ts`

```ts
export type SenderType = 'STORE' | 'CUSTOMER' | 'COURIER' | 'SYSTEM';

export interface MessageResponse {
  id: number;
  orderId: number;
  senderId: string;
  senderType: SenderType;
  content: string;
  sentAt: string;  // ISO 8601
  readAt: string | null;
}
```

### Formato de Erro do Backend (`ErrorResponse`)

```ts
export interface ErrorResponse {
  code: string;    // NOT_FOUND, INVALID_STATE, VALIDATION_ERROR, BAD_REQUEST, FORBIDDEN, INTERNAL_ERROR
  message: string;
}
```

## 14. Paginas e Funcionalidades

### DashboardPage (`/dashboard`)
- KPI Cards: total pedidos hoje, ticket medio, pedidos em andamento, entregadores ativos
- Grafico de barras: vendas ultimos 7 dias (Recharts `BarChart`)
- Grafico de pizza: top 5 produtos mais vendidos (Recharts `PieChart`)
- Lista de pedidos ativos (resumo, clicavel para detalhes)
- Dados via `GET /api/reports/dashboard` + `GET /api/orders/active`

### ProductListPage (`/products`)
- Tabela paginada: nome, categoria, preco, estoque, status (ativo/inativo), acoes
- Filtros por nome/categoria/disponibilidade
- Toggle disponibilidade inline (PATCH `/availability`)
- Soft delete com ConfirmDialog
- Badge vermelho em produtos com estoque abaixo do minimo

### ProductFormPage (`/products/new` e `/products/:id/edit`)
- Campos: nome, descricao, preco, categoria (select), URL imagem, estoque, estoque minimo
- Validacao com Zod via React Hook Form
- Ao editar, carrega dados atuais do produto

### OrdersPage (`/orders`)
- **Painel Kanban** com colunas: PENDENTE | EM PREPARO | PRONTO | SAIU PARA ENTREGA
- Cards: numero do pedido, nome cliente, valor total, tempo desde criacao
- Clique abre OrderDetailModal
- Lista secundaria filtravel com paginacao
- Polling a cada 10s + som + toast ao detectar novo pedido PENDING

### OrderDetailPage (`/orders/:id`)
- Dados completos: cliente, endereco, itens (produto, qtd, subtotal), total, observacoes
- Timeline do pedido (historico de status com timestamp)
- Acoes por status atual:
  - PENDING → "Aceitar" / "Recusar" (abre RejectOrderModal)
  - ACCEPTED → "Iniciar Preparo"
  - PREPARING → "Pronto para Retirada"
  - READY → "Saiu para Entrega" (abre AssignCourierModal se sem entregador)
  - OUT_FOR_DELIVERY → "Finalizar Entrega"
- ChatPanel embutido (WebSocket/STOMP)

### CouriersPage (`/couriers`)
- Tabela: nome, telefone, veiculo, status (AVAILABLE/BUSY/OFFLINE), ativo
- Modal cadastro/edicao com CourierForm
- Toggle ativo/inativo

### DeliveriesPage (`/deliveries`)
- Tabela entregas em andamento: pedido, entregador, status, atribuido em
- Botao para atribuir/reatribuir entregador (AssignCourierModal)

### ReportsPage (`/reports`)
- DateRangePicker para selecionar periodo
- Tabela relatorio de vendas por dia
- Grafico de linha: evolucao de pedidos (Recharts `LineChart`)
- Cards metricas: total pedidos, total faturado, ticket medio, taxa aceitacao
- Lista top produtos mais vendidos

### SettingsPage (`/settings`)
- Gerenciamento de categorias: listar, criar, editar nome
- Somente ADMIN

## 15. Tratamento de Erros

- Exibir mensagem de erro via **toast** (React Toastify) quando requisicao falhar
- Formato do erro do backend: `{ "code": "...", "message": "..." }`
- Interceptor Axios de resposta para tratar erros globalmente:
  - 401 → Keycloak refresh token ou redireciona para login
  - 403 → Toast "Acesso negado"
  - 404 → Toast "Recurso nao encontrado"
  - 422 → Toast com a mensagem do backend (estado invalido)
  - 500 → Toast "Erro interno do servidor"

## 16. Ordem de Implementacao Sugerida

1. **Boilerplate** — Vite + TypeScript + TailwindCSS + ESLint + configurar porta 3000
2. **Autenticacao** — Keycloak provider + Axios interceptor + variaveis de ambiente
3. **Layout base** — MainLayout, Sidebar, Header, PrivateRoute, RoleGuard
4. **Componentes UI** — Button, Input, Select, Modal, Badge, Spinner, Table, Pagination
5. **Dashboard** — DashboardPage com KPIs e graficos
6. **Catalogo** — ProductListPage + ProductFormPage + hooks + types
7. **Pedidos** — OrdersPage + OrderDetailModal + polling + notificacoes
8. **Entregas** — CouriersPage + DeliveriesPage + AssignCourierModal
9. **Chat** — ChatPanel + useChatWebSocket + chatNotificationStore
10. **Relatorios** — ReportsPage com graficos e filtros de data
11. **Configuracoes** — SettingsPage com gerenciamento de categorias

## 17. Restricoes Obrigatorias

1. **NAO criar backend proprio** — apenas consumir APIs do backend Spring Boot existente
2. **NAO usar Redux** — TanStack Query para server state, Zustand apenas para UI state
3. **NAO usar CSS global** — apenas classes utilitarias TailwindCSS
4. **Textos da interface em portugues do Brasil**
5. **Sempre tipar com TypeScript** — proibido usar `any`
6. **Tratar erros de API** — toast com mensagem amigavel ao usuario
7. **Tokens JWT** — NUNCA armazenar em localStorage; Keycloak JS gerencia em memoria
8. **Porta do Vite** — DEVE ser 3000 (Keycloak redirect URIs configuradas para localhost:3000)
9. **Acessibilidade minima** — `aria-label` em botoes de icone, foco visivel nos inputs
10. **Responsividade** — desktop first (1280px+), suporte minimo 1024px

## 18. Referencia a Documentacao

Documentacao completa do projeto em `../docs/`:

| Arquivo | Conteudo |
|---|---|
| `01-visao-do-projeto.md` | Escopo, stakeholders, capacidades |
| `02-requisitos.md` | Requisitos funcionais, nao-funcionais, regras de negocio |
| `03-arquitetura.md` | Decisoes arquiteturais, DDD, camadas |
| `04-modelagem-banco-dados.md` | Schemas, tabelas, relacionamentos |
| `05-diagramas.md` | Diagramas de componentes, sequencia, C4 |
| `06-chat-tempo-real.md` | WebSocket/STOMP, fluxo de mensagens |
| `07-planejamento-sprints.md` | 7 sprints de 2 semanas |
| `08-justificativa-academica.md` | Cobertura das 4 disciplinas |
| `09-integracao-keycloak.md` | Setup Keycloak, fluxos OAuth2 |
| `PROMPT-AGENTE-FRONTEND.md` | Instrucoes originais (ATENCAO: enums de CourierStatus e DeliveryStatus estao incorretos neste doc — usar os valores deste CLAUDE.md) |

### Backend CLAUDE.md

Referencia completa da API, arquitetura, e regras de negocio em `../backoffice-backend/CLAUDE.md`.
