## Context

O frontend ja usa `toast.success/error` em mutations individuais (ex: CategoryManager, OrderDetailPage), mas falta:
1. O `<ToastContainer />` no app — sem ele, nenhum toast aparece na tela
2. O import do CSS do React Toastify — sem ele, o toast nao tem estilizacao
3. Um interceptor de resposta Axios para tratar erros HTTP globalmente — sem ele, cada mutation precisa tratar erros individualmente

O `src/config/axios.ts` tem apenas um request interceptor (JWT). O `src/main.tsx` nao importa o CSS do React Toastify nem renderiza o ToastContainer.

## Goals / Non-Goals

**Goals:**
- Adicionar interceptor de resposta Axios para tratar erros HTTP (401, 403, 404, 400, 422, 500) com toasts
- Adicionar `<ToastContainer />` e CSS do React Toastify no `main.tsx`
- Definir tipo `ErrorResponse` em `src/types/error.types.ts`
- Usar a `message` do corpo da resposta quando disponivel no formato `ErrorResponse`

**Non-Goals:**
- Remover tratamento de erro local das mutations existentes (eles continuam como fallback)
- Implementar retry automatico de requests
- Tratar erros de rede (offline) — apenas erros HTTP do backend

## Decisions

### 1. Interceptor no mesmo arquivo `src/config/axios.ts`
O response interceptor sera adicionado no mesmo arquivo da instancia Axios, logo apos o request interceptor existente. Alternativa descartada: criar arquivo separado — desnecessario para um unico interceptor.

### 2. ToastContainer no `main.tsx` (nao no App.tsx)
O ToastContainer ficara no `main.tsx` junto com os providers, garantindo que esta disponivel globalmente mesmo fora do React Router. O CSS do React Toastify sera importado no `main.tsx` junto ao `index.css`.

### 3. Erro 401 delega ao Keycloak
Para 401, o interceptor chama `keycloak.login()` para forcar re-autenticacao, sem exibir toast (o redirect ja comunica ao usuario). Isso complementa o request interceptor que ja tenta refresh preventivo.

### 4. Mensagens fallback por status code
Quando o body nao contem `ErrorResponse` valido (sem campo `message`), usar mensagens fixas em portugues por status code.

## Risks / Trade-offs

- **Toast duplicado**: Se uma mutation tem `onError` com `toast.error()` E o interceptor tambem exibe toast, o usuario ve dois toasts. → Mitigacao: O interceptor trata apenas erros globais; mutations podem optar por suprimir o toast local ou manter para mensagens mais especificas. Nao sera alterado agora — melhoria futura se necessario.
- **Erro 401 sem toast**: O usuario nao ve feedback visual antes do redirect. → Aceitavel pois o redirect para login e suficiente.
