## Context

O diretorio `backoffice-frontend/` esta vazio (sem codigo). O backend Spring Boot ja esta funcional em `logdash-backend/` com APIs REST, WebSocket/STOMP e autenticacao via Keycloak. O frontend sera uma SPA React que consome essas APIs.

A infraestrutura (PostgreSQL + Keycloak) sobe via `docker-compose` no backend. O Keycloak ja tem o realm `logdash` com o client `backoffice-webapp` (public, PKCE) e redirect URIs para `localhost:3000`.

## Goals / Non-Goals

**Goals:**
- Projeto Vite + React 18 + TypeScript 5 funcional e buildavel
- TailwindCSS configurado com tema customizado (primary laranja, sidebar slate-800)
- Autenticacao completa via Keycloak (login, logout, refresh automatico, PKCE)
- Axios com interceptor JWT que injeta Bearer token em todas as requests
- TanStack Query configurado como provider global
- Estrutura de pastas feature-based conforme CLAUDE.md
- `.env.example` com todas as variaveis de ambiente

**Non-Goals:**
- Layout (Sidebar, Header) — sera a proxima change
- Roteamento e guards (PrivateRoute, RoleGuard) — proxima change
- Qualquer feature de negocio (dashboard, produtos, pedidos, etc.)
- Componentes UI reutilizaveis
- WebSocket/STOMP
- Zustand stores

## Decisions

### 1. Vite na porta 3000

**Decisao**: Configurar `server.port: 3000` no `vite.config.ts`.
**Razao**: O Keycloak realm (`logdash-realm.json`) tem redirect URIs apenas para `localhost:3000` e `localhost:8081`. A porta default do Vite (5173) nao esta autorizada.
**Alternativa descartada**: Alterar o realm JSON para adicionar localhost:5173 — evitamos mexer na config do backend.

### 2. keycloak-js + @react-keycloak/web

**Decisao**: Usar `keycloak-js` diretamente com o wrapper `@react-keycloak/web` para o Provider.
**Razao**: Stack definida no CLAUDE.md. O Provider garante que o app so renderiza apos autenticacao (`onLoad: 'login-required'`).
**Alternativa descartada**: `oidc-client-ts` — mais generico mas nao tem wrapper React pronto e o CLAUDE.md define keycloak-js.

### 3. Axios interceptor para JWT

**Decisao**: Instancia Axios unica em `src/config/axios.ts` com interceptor que faz refresh automatico do token se expirado em <30s.
**Razao**: Todas as chamadas ao backend exigem Bearer token. O interceptor centraliza essa logica e evita repetição em cada hook.
**Alternativa descartada**: Fetch API nativa — nao tem interceptors nativos, precisaria de wrapper manual.

### 4. Estrutura feature-based

**Decisao**: Organizar codigo por feature (`features/catalog/`, `features/orders/`, etc.) com `pages/`, `components/`, `hooks/`, `types/` dentro de cada.
**Razao**: Definido no CLAUDE.md. Escala melhor que organizar por tipo de arquivo.

### 5. TailwindCSS 3 com PostCSS

**Decisao**: TailwindCSS 3 + PostCSS + Autoprefixer. Nao usar Tailwind 4.
**Razao**: CLAUDE.md especifica TailwindCSS 3. As versoes de dependencia estao fixadas no package.json de referencia.

## Risks / Trade-offs

- **@react-keycloak/web pode estar desatualizado** → Caso tenha problemas de compatibilidade com React 18, podemos criar um provider customizado simples que wrapa o keycloak-js diretamente. E um wrapper fino.
- **Porta 3000 pode conflitar com outro servico** → Se o dev ja roda algo na 3000, tera que parar. Documentar isso no .env.example.
- **Token refresh race condition** → O interceptor Axios faz `updateToken(30)` antes de cada request. Se duas requests simultaneas detectam token expirado, ambas tentam refresh. O keycloak-js internamente serializa isso, entao nao eh problema.
