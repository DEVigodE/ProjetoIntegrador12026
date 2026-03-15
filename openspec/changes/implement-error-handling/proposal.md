## Why

O frontend ja usa `toast.success/error` em todas as mutations, mas falta o `<ToastContainer />` no app (os toasts nao aparecem sem ele) e o interceptor de resposta do Axios para tratar erros HTTP globalmente. Sem o interceptor, cada mutation precisa tratar erros individualmente; com ele, erros comuns (401, 403, 404, 422, 500) sao tratados centralmente com mensagens amigaveis.

## What Changes

- Adicionar interceptor de resposta no `src/config/axios.ts` que trata erros HTTP com toast e mensagens baseadas no `ErrorResponse` do backend
- Adicionar `<ToastContainer />` e import do CSS do React Toastify no `src/main.tsx`
- Definir tipo `ErrorResponse` em `src/types/error.types.ts`

## Capabilities

### New Capabilities

### Modified Capabilities
- `error-handling`: Implementacao do interceptor de resposta Axios e ToastContainer

## Impact

- **Codigo afetado**: `src/config/axios.ts` (adicionar response interceptor), `src/main.tsx` (adicionar ToastContainer + CSS)
- **Novo arquivo**: `src/types/error.types.ts`
- **Dependencias existentes**: React Toastify, Axios (ja instalados)
