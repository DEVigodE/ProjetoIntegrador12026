## 1. Tipo ErrorResponse

- [ ] 1.1 Criar `src/types/error.types.ts` com a interface `ErrorResponse` (code: string, message: string)

## 2. Interceptor de resposta Axios

- [ ] 2.1 Adicionar response interceptor em `src/config/axios.ts` que trata erros 401, 403, 404, 400, 422, 500 com toasts e mensagens fallback em portugues

## 3. ToastContainer e CSS

- [ ] 3.1 Adicionar import do CSS do React Toastify e `<ToastContainer />` em `src/main.tsx`
