# Keycloak Auth

Autenticacao OAuth2/OIDC via Keycloak para o backoffice.

## Requirements

### Requirement: Instancia Keycloak configurada
O sistema SHALL ter um modulo `src/config/keycloak.ts` que exporta uma instancia do Keycloak configurada com variaveis de ambiente (VITE_KEYCLOAK_URL, VITE_KEYCLOAK_REALM, VITE_KEYCLOAK_CLIENT_ID).

#### Scenario: Keycloak instanciado com variaveis de ambiente
- **WHEN** importar `keycloak` de `src/config/keycloak.ts`
- **THEN** a instancia esta configurada com url=VITE_KEYCLOAK_URL, realm=VITE_KEYCLOAK_REALM, clientId=VITE_KEYCLOAK_CLIENT_ID

### Requirement: Provider Keycloak no ponto de entrada
O sistema SHALL usar `ReactKeycloakProvider` no `src/main.tsx` com `onLoad: 'login-required'` e `pkceMethod: 'S256'`, garantindo que o app so renderiza apos autenticacao.

#### Scenario: App protegido por login
- **WHEN** o usuario acessa qualquer URL do app sem estar autenticado
- **THEN** ele e redirecionado automaticamente para a tela de login do Keycloak

#### Scenario: PKCE habilitado
- **WHEN** o fluxo de autenticacao inicia
- **THEN** ele usa Authorization Code com PKCE (S256) conforme configurado no client `backoffice-webapp`

#### Scenario: Loading enquanto autentica
- **WHEN** o Keycloak esta inicializando
- **THEN** o app exibe um componente de loading (AuthLoadingScreen)

### Requirement: Interceptor Axios com JWT
O sistema SHALL ter um modulo `src/config/axios.ts` que exporta uma instancia Axios com baseURL e interceptor de request que injeta o Bearer token do Keycloak.

#### Scenario: Token injetado em requests
- **WHEN** uma request HTTP e feita usando a instancia Axios
- **THEN** o header `Authorization: Bearer <token>` e adicionado automaticamente

#### Scenario: Token expirado e renovado automaticamente
- **WHEN** o token do Keycloak expira em menos de 30 segundos
- **THEN** o interceptor faz `updateToken(30)` antes de enviar a request

#### Scenario: BaseURL configurada
- **WHEN** a instancia Axios e criada
- **THEN** a `baseURL` aponta para `VITE_API_BASE_URL` (http://localhost:8081)

### Requirement: Logout
O sistema SHALL permitir que o usuario faca logout via `keycloak.logout()`.

#### Scenario: Usuario faz logout
- **WHEN** o usuario clica no botao "Sair"
- **THEN** a sessao e encerrada e o usuario e redirecionado para a tela de login do Keycloak

### Requirement: Tokens nunca em localStorage
O sistema SHALL NUNCA armazenar tokens JWT em localStorage. O Keycloak JS gerencia tokens em memoria.

#### Scenario: Nenhum token persistido
- **WHEN** inspecionar o localStorage do navegador
- **THEN** nao ha tokens JWT armazenados
