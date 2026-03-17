## ADDED Requirements

### Requirement: QueryClient configurado
O sistema SHALL ter um modulo `src/config/queryClient.ts` que exporta uma instancia do QueryClient do TanStack Query v5 com configuracoes padrao sensatas.

#### Scenario: QueryClient criado com defaults
- **WHEN** importar `queryClient` de `src/config/queryClient.ts`
- **THEN** ele e uma instancia de `QueryClient` com `defaultOptions` configuradas (staleTime, retry)

### Requirement: QueryClientProvider no ponto de entrada
O sistema SHALL envolver o `<App />` com `<QueryClientProvider>` no `src/main.tsx`, dentro do `ReactKeycloakProvider`.

#### Scenario: Provider aninhado corretamente
- **WHEN** a arvore de componentes renderiza
- **THEN** a hierarquia e: `ReactKeycloakProvider` > `QueryClientProvider` > `App`
