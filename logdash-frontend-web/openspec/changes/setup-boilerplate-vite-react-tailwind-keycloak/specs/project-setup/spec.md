## ADDED Requirements

### Requirement: Projeto Vite com React e TypeScript
O sistema SHALL ser criado como um projeto Vite com template `react-ts`, gerando a estrutura base com React 18 e TypeScript 5.

#### Scenario: Projeto criado com sucesso
- **WHEN** executar `npm create vite@latest logdash-frontend-web -- --template react-ts`
- **THEN** o diretorio `logdash-frontend-web/` contem `package.json`, `vite.config.ts`, `tsconfig.json` e `src/main.tsx`

### Requirement: Vite configurado na porta 3000
O servidor de desenvolvimento SHALL rodar na porta 3000 conforme exigido pelas redirect URIs do Keycloak.

#### Scenario: Dev server inicia na porta correta
- **WHEN** executar `npm run dev`
- **THEN** o servidor inicia em `http://localhost:3000`

#### Scenario: Configuracao no vite.config.ts
- **WHEN** o arquivo `vite.config.ts` for lido
- **THEN** ele contem `server: { port: 3000 }`

### Requirement: TailwindCSS com tema customizado
O sistema SHALL usar TailwindCSS 3 com PostCSS e Autoprefixer, com tema estendido contendo cores `primary-500` (#f97316), `primary-600` (#ea580c) e `sidebar` (#1e293b).

#### Scenario: Tailwind configurado
- **WHEN** o arquivo `tailwind.config.ts` for lido
- **THEN** ele contem as cores customizadas e o content aponta para `./index.html` e `./src/**/*.{ts,tsx}`

#### Scenario: PostCSS configurado
- **WHEN** o arquivo `postcss.config.js` for lido
- **THEN** ele inclui os plugins `tailwindcss` e `autoprefixer`

### Requirement: Todas as dependencias instaladas
O sistema SHALL ter todas as dependencias definidas no CLAUDE.md instaladas no `package.json`.

#### Scenario: Dependencias de producao presentes
- **WHEN** verificar o `package.json`
- **THEN** ele contem: react, react-dom, react-router-dom, @tanstack/react-query, axios, keycloak-js, @react-keycloak/web, @stomp/stompjs, sockjs-client, zustand, react-hook-form, zod, @hookform/resolvers, recharts, react-toastify, date-fns

#### Scenario: Dependencias de desenvolvimento presentes
- **WHEN** verificar o `package.json`
- **THEN** ele contem: tailwindcss, postcss, autoprefixer, @types/sockjs-client, @types/react, @types/react-dom, @vitejs/plugin-react, typescript, vite

### Requirement: Estrutura de pastas feature-based
O sistema SHALL ter a estrutura de pastas definida no CLAUDE.md criada (diretorios vazios com .gitkeep onde necessario).

#### Scenario: Diretorios base existem
- **WHEN** listar `src/`
- **THEN** existem os diretorios: `config/`, `routes/`, `layouts/`, `components/ui/`, `components/layout/`, `components/shared/`, `features/`, `store/`, `services/`, `utils/`

### Requirement: Variaveis de ambiente documentadas
O sistema SHALL ter um arquivo `.env.example` com todas as variaveis de ambiente necessarias e valores padrao de desenvolvimento.

#### Scenario: .env.example existe com valores corretos
- **WHEN** ler o arquivo `.env.example`
- **THEN** ele contem: VITE_API_BASE_URL=http://localhost:8081, VITE_KEYCLOAK_URL=http://localhost:8080, VITE_KEYCLOAK_REALM=logdash, VITE_KEYCLOAK_CLIENT_ID=backoffice-webapp, VITE_WS_URL=http://localhost:8081/ws
