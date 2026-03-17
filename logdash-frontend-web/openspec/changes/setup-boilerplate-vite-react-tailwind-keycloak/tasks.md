## 1. Scaffolding do Projeto Vite

- [x] 1.1 Criar projeto com `npm create vite@latest logdash-frontend-web -- --template react-ts`
- [x] 1.2 Instalar dependencias de producao (react-router-dom, @tanstack/react-query, axios, keycloak-js, @react-keycloak/web, @stomp/stompjs, sockjs-client, zustand, react-hook-form, zod, @hookform/resolvers, recharts, react-toastify, date-fns)
- [x] 1.3 Instalar dependencias de desenvolvimento (tailwindcss, postcss, autoprefixer, @types/sockjs-client)

## 2. Configuracao TailwindCSS

- [x] 2.1 Criar `tailwind.config.ts` com tema customizado (primary-500: #f97316, primary-600: #ea580c, sidebar: #1e293b) e content apontando para index.html + src/**/*.{ts,tsx}
- [x] 2.2 Criar `postcss.config.js` com plugins tailwindcss e autoprefixer
- [x] 2.3 Adicionar diretivas Tailwind (@tailwind base, components, utilities) no arquivo CSS principal (`src/index.css`)

## 3. Configuracao Vite

- [x] 3.1 Configurar `vite.config.ts` com `server.port: 3000` e plugin React

## 4. Variaveis de Ambiente

- [x] 4.1 Criar `.env.example` com VITE_API_BASE_URL, VITE_KEYCLOAK_URL, VITE_KEYCLOAK_REALM, VITE_KEYCLOAK_CLIENT_ID, VITE_WS_URL
- [x] 4.2 Criar `.env` (copia do .env.example com valores de dev) e adicionar `.env` ao `.gitignore`

## 5. Estrutura de Pastas

- [x] 5.1 Criar diretorios: src/config/, src/routes/, src/layouts/
- [x] 5.2 Criar diretorios: src/components/ui/, src/components/layout/, src/components/shared/
- [x] 5.3 Criar diretorios de features: src/features/dashboard/, src/features/catalog/, src/features/orders/, src/features/delivery/, src/features/chat/, src/features/reports/, src/features/settings/
- [x] 5.4 Criar diretorios: src/store/, src/services/, src/utils/

## 6. Configuracao Keycloak

- [x] 6.1 Criar `src/config/keycloak.ts` exportando instancia Keycloak com url, realm e clientId lidos de import.meta.env
- [x] 6.2 Atualizar `src/main.tsx` com ReactKeycloakProvider (onLoad: login-required, pkceMethod: S256) e componente AuthLoadingScreen inline

## 7. Configuracao Axios

- [x] 7.1 Criar `src/config/axios.ts` com instancia Axios (baseURL de VITE_API_BASE_URL) e interceptor de request que injeta Bearer token e faz refresh automatico com updateToken(30)

## 8. Configuracao TanStack Query

- [x] 8.1 Criar `src/config/queryClient.ts` exportando QueryClient com defaultOptions (staleTime, retry)
- [x] 8.2 Adicionar QueryClientProvider no main.tsx envolvendo App, dentro do ReactKeycloakProvider

## 9. App Minimo Funcional

- [x] 9.1 Criar `src/App.tsx` com componente placeholder que exibe nome do usuario autenticado (keycloak.tokenParsed?.name) e botao de logout
- [x] 9.2 Limpar arquivos desnecessarios do template Vite (App.css com conteudo default, assets/react.svg, etc.)
- [x] 9.3 Verificar que `npm run dev` inicia sem erros na porta 3000
