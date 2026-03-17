## 1. Auth & Route Guards

- [x] 1.1 Create `src/routes/PrivateRoute.tsx` — checks `keycloak.authenticated`, calls `keycloak.login()` if not authenticated, renders `<Outlet />` if authenticated
- [x] 1.2 Create `src/routes/RoleGuard.tsx` — reads roles from `keycloak.tokenParsed?.realm_access?.roles`, renders children if user has at least one required role, otherwise renders "Acesso negado" message

## 2. Layout Components

- [x] 2.1 Create `src/components/layout/Sidebar.tsx` — static nav config array `{ path, label, roles }`, filters items by user role, highlights active item with `primary-500`, shows pending orders badge from `orderNotificationStore`, slate-800 background, logout button
- [x] 2.2 Create `src/components/layout/Header.tsx` — white background with shadow, displays page title, user name from `keycloak.tokenParsed?.name`, logout button
- [x] 2.3 Create `src/components/layout/PageHeader.tsx` — accepts `title` and optional `breadcrumb` props, renders page heading
- [x] 2.4 Create `src/layouts/MainLayout.tsx` — composes Sidebar + Header + `<Outlet />` content area in a flex layout
- [x] 2.5 Create `src/layouts/AuthLayout.tsx` — centered spinner with "Autenticando..." text, used as Keycloak loading component

## 3. Placeholder Pages

- [x] 3.1 Create `src/features/dashboard/pages/DashboardPage.tsx` — renders PageHeader with "Dashboard"
- [x] 3.2 Create `src/features/catalog/pages/ProductListPage.tsx` — renders PageHeader with "Produtos"
- [x] 3.3 Create `src/features/catalog/pages/ProductFormPage.tsx` — renders PageHeader with "Novo Produto" or "Editar Produto"
- [x] 3.4 Create `src/features/orders/pages/OrdersPage.tsx` — renders PageHeader with "Pedidos"
- [x] 3.5 Create `src/features/orders/pages/OrderDetailPage.tsx` — renders PageHeader with "Detalhes do Pedido"
- [x] 3.6 Create `src/features/delivery/pages/CouriersPage.tsx` — renders PageHeader with "Entregadores"
- [x] 3.7 Create `src/features/delivery/pages/DeliveriesPage.tsx` — renders PageHeader with "Entregas"
- [x] 3.8 Create `src/features/reports/pages/ReportsPage.tsx` — renders PageHeader with "Relatorios"
- [x] 3.9 Create `src/features/settings/pages/SettingsPage.tsx` — renders PageHeader with "Configuracoes"

## 4. Router Configuration

- [x] 4.1 Create smart root redirect component that redirects `/` to `/dashboard` for ADMIN/OPERATOR or `/deliveries` for DISPATCHER
- [x] 4.2 Rewrite `src/App.tsx` with React Router route definitions — PrivateRoute as parent, MainLayout as layout route, RoleGuard wrapping each feature route with appropriate roles
- [x] 4.3 Update `src/main.tsx` to wrap App with `<BrowserRouter>`

## 5. Zustand Store Setup

- [x] 5.1 Create `src/store/orderNotificationStore.ts` — Zustand store with `pendingCount`, `setPendingCount`, `increment`, `clear` actions (used by Sidebar badge)

## 6. Verification

- [x] 6.1 Run `npm run build` in `logdash-frontend-web/` to verify TypeScript compilation and no import errors
