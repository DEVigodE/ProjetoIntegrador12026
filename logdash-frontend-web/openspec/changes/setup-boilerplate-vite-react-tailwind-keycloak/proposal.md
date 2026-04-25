## Why

O projeto `logdash-frontend-web/` ainda nao possui codigo. Precisamos criar a base do projeto (boilerplate) com Vite + React + TypeScript + TailwindCSS e integrar a autenticacao via Keycloak. Sem essa fundacao, nenhuma feature pode ser desenvolvida. Esta e a etapa 1 e 2 da ordem de implementacao definida no CLAUDE.md.

## What Changes

- Criar projeto React 18 + TypeScript 5 com Vite como bundler
- Configurar TailwindCSS 3 com tema customizado (cores primary laranja, sidebar slate-800)
- Configurar Vite para rodar na porta 3000 (exigido pelas redirect URIs do Keycloak)
- Instalar todas as dependencias do stack definido no CLAUDE.md
- Configurar autenticacao OAuth2/OIDC com Keycloak usando `keycloak-js` + `@react-keycloak/web`
- Criar instancia Axios com interceptor JWT (refresh automatico de token)
- Criar instancia TanStack Query (QueryClient)
- Criar arquivo `.env.example` com variaveis de ambiente documentadas
- Configurar estrutura base de pastas (`config/`, `routes/`, `layouts/`, `components/`, `features/`, `store/`, `services/`, `utils/`)

## Capabilities

### New Capabilities
- `project-setup`: Scaffolding Vite + React + TS + TailwindCSS, instalacao de dependencias, configuracao de porta e tema
- `keycloak-auth`: Integracao Keycloak (provider, config, interceptor Axios JWT, variaveis de ambiente)
- `query-client`: Configuracao do TanStack Query v5 (QueryClient + provider)

### Modified Capabilities

## Impact

- **Codigo**: Cria toda a estrutura base em `logdash-frontend-web/src/`
- **Dependencias**: Instala ~20 pacotes (React, TailwindCSS, Axios, Keycloak-js, TanStack Query, Zustand, etc.)
- **Configuracao**: `vite.config.ts`, `tailwind.config.ts`, `tsconfig.json`, `postcss.config.js`, `.env.example`
- **Keycloak**: Depende do Keycloak rodando em `localhost:8080` com realm `logdash` e client `backoffice-webapp`
- **Backend**: Depende do backend rodando em `localhost:8081` para chamadas autenticadas
