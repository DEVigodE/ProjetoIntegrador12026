## Context

The frontend project (`backoffice-frontend/`) is bootstrapped with Vite + React 19 + TypeScript. Dependencies are installed (react-router-dom v7, @react-keycloak/web, zustand, tailwindcss v4). The `main.tsx` already wraps the app with `ReactKeycloakProvider` and `QueryClientProvider`. However, `App.tsx` is a static welcome page — no routing, no layout shell. The directory structure has empty placeholder folders (`src/layouts/`, `src/routes/`, `src/components/layout/`, `src/features/*/`).

The backend is fully implemented with REST APIs, Keycloak realm configured with three roles (ADMIN, OPERATOR, DISPATCHER), and three test users.

## Goals / Non-Goals

**Goals:**
- Implement the full layout shell (Sidebar + Header + content area) so feature pages render inside a consistent chrome
- Configure React Router with all application routes, protected by authentication and role-based guards
- Create placeholder pages for every route so the navigation works end-to-end
- Wire up the `orderNotificationStore` badge in the Sidebar for pending orders count

**Non-Goals:**
- Implementing actual feature page content (dashboard charts, product tables, etc.) — placeholder pages only
- Building reusable UI components (Button, Input, Modal, etc.) — separate change
- WebSocket/STOMP integration — separate change
- Responsive/mobile layout — desktop-first (1280px+), mobile support is out of scope for this change

## Decisions

### 1. React Router v7 with layout routes

Use React Router's `<Outlet />` pattern with `MainLayout` as a layout route wrapping all authenticated routes. This avoids duplicating layout rendering in every page.

**Alternative considered**: Wrapping each route manually with `<MainLayout>` — rejected because it's repetitive and harder to maintain.

### 2. BrowserRouter in main.tsx

Wrap the entire app with `<BrowserRouter>` in `main.tsx`, outside of `App.tsx`. This keeps `App.tsx` focused on route definitions and allows router hooks anywhere in the tree.

### 3. PrivateRoute uses useKeycloak hook

`PrivateRoute` checks `keycloak.authenticated` from `@react-keycloak/web`. If not authenticated, it calls `keycloak.login()` to redirect to Keycloak. No custom redirect handling needed since Keycloak manages the OAuth flow.

### 4. RoleGuard reads roles from JWT

`RoleGuard` reads `keycloak.tokenParsed?.realm_access?.roles` and checks if the user has at least one of the required roles. If not, it renders an "Access Denied" message rather than redirecting — the user is authenticated but lacks permissions.

**Alternative considered**: Redirecting to `/dashboard` on role mismatch — rejected because it creates confusing loops if the user also lacks dashboard access (DISPATCHER has no dashboard role).

### 5. Sidebar items defined as a static config array

Define sidebar navigation items as a typed array with `{ path, label, icon, roles }`. Filter at render time based on user roles. This is simpler than dynamic registration and sufficient for a fixed menu.

### 6. Placeholder pages as minimal components

Each feature page will be a simple component rendering just the page title. This validates routing works without building real content. Pages will be in their final locations (`src/features/*/pages/`) so no file moves are needed later.

### 7. useLocation for active sidebar item

Use React Router's `useLocation()` to determine which sidebar item is active by matching the current pathname prefix. Simple string matching (`pathname.startsWith(item.path)`) is sufficient for the flat route structure.

## Risks / Trade-offs

- **[Risk] Keycloak initialization delay**: The `ReactKeycloakProvider` may show the auth loading screen for several seconds on first load. → Mitigation: `AuthLayout` provides visual feedback with a spinner. This is inherent to the OAuth flow and acceptable.

- **[Risk] DISPATCHER has no dashboard access**: If a DISPATCHER navigates to `/`, they get redirected to `/dashboard` which they can't access. → Mitigation: The root redirect should check user role and redirect to the first accessible route (e.g., `/deliveries` for DISPATCHER).

- **[Trade-off] Placeholder pages add temporary code**: Every feature page starts as a stub that will be replaced. → Acceptable because it validates the full routing tree and provides anchor points for feature development.
