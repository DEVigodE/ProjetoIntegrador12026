## Why

The frontend project has been bootstrapped with Vite, React, TypeScript, and all dependencies installed, but `App.tsx` is still a static welcome page with no routing or layout. Without a layout shell and route configuration, no feature pages can be developed or navigated to. This is the foundational change that unblocks all subsequent feature work.

## What Changes

- Create `MainLayout` component with fixed Sidebar (slate-800 background, role-filtered menu items, pending orders badge), Header (user name, logout, page title), and `<Outlet />` content area
- Create `AuthLayout` with spinner shown during Keycloak initialization
- Create `Sidebar` and `Header` layout components
- Create `PageHeader` component with title and optional breadcrumb
- Implement `PrivateRoute` guard that redirects unauthenticated users to Keycloak login
- Implement `RoleGuard` component that restricts route access by user role (ADMIN, OPERATOR, DISPATCHER)
- Configure React Router with BrowserRouter and the full route map (dashboard, products, orders, couriers, deliveries, reports, settings)
- Replace the static `App.tsx` with the router configuration using `MainLayout` as the layout route
- Create placeholder pages for each route so navigation works end-to-end
- Redirect `/` to `/dashboard`

## Capabilities

### New Capabilities
_(No new spec capabilities — this change implements existing specs)_

### Modified Capabilities
- `layout`: Implementing all layout requirements (MainLayout, Sidebar, Header, PageHeader, AuthLayout)
- `routing`: Implementing all routing requirements (PrivateRoute, RoleGuard, full route map, MainLayout integration)

## Impact

- **Files created**: `src/layouts/MainLayout.tsx`, `src/layouts/AuthLayout.tsx`, `src/components/layout/Sidebar.tsx`, `src/components/layout/Header.tsx`, `src/components/layout/PageHeader.tsx`, `src/routes/PrivateRoute.tsx`, `src/routes/RoleGuard.tsx`, placeholder pages in `src/features/*/pages/`
- **Files modified**: `src/App.tsx` (replaced with router config), `src/main.tsx` (wrap with BrowserRouter)
- **Dependencies used**: `react-router-dom` (already installed), `@react-keycloak/web` (already installed), `zustand` (already installed for orderNotificationStore)
- **No backend changes required**
