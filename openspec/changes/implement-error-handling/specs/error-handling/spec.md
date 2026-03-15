## MODIFIED Requirements

### Requirement: Interceptor de resposta Axios
O sistema SHALL ter um interceptor de resposta no Axios que trata erros HTTP globalmente, exibindo toasts com mensagens amigaveis. O interceptor SHALL extrair a `message` do corpo da resposta quando no formato `ErrorResponse`, e usar mensagens fallback em portugues quando o corpo nao estiver no formato esperado.

#### Scenario: Erro 401 - nao autenticado
- **WHEN** o backend retorna 401
- **THEN** o sistema redireciona para login via `keycloak.login()` sem exibir toast

#### Scenario: Erro 403 - acesso negado
- **WHEN** o backend retorna 403
- **THEN** um toast error exibe a mensagem do backend ou "Acesso negado" como fallback

#### Scenario: Erro 404 - recurso nao encontrado
- **WHEN** o backend retorna 404
- **THEN** um toast error exibe a mensagem do backend ou "Recurso nao encontrado" como fallback

#### Scenario: Erro 422 - estado invalido
- **WHEN** o backend retorna 422 com body `{ code: "INVALID_STATE", message: "Pedido ja foi aceito" }`
- **THEN** um toast error exibe "Pedido ja foi aceito"

#### Scenario: Erro 400 - validacao
- **WHEN** o backend retorna 400 com body `{ code: "VALIDATION_ERROR", message: "..." }`
- **THEN** um toast error exibe a mensagem de validacao do backend

#### Scenario: Erro 500 - erro interno
- **WHEN** o backend retorna 500
- **THEN** um toast error exibe a mensagem do backend ou "Erro interno do servidor" como fallback

#### Scenario: Erro sem body JSON valido
- **WHEN** o backend retorna erro HTTP sem body ou com body que nao segue formato ErrorResponse
- **THEN** o interceptor usa a mensagem fallback correspondente ao status code

### Requirement: Formato ErrorResponse do backend
O sistema SHALL esperar o seguinte formato de erro do backend:

```ts
interface ErrorResponse {
  code: string;   // NOT_FOUND | INVALID_STATE | VALIDATION_ERROR | BAD_REQUEST | FORBIDDEN | INTERNAL_ERROR
  message: string;
}
```

#### Scenario: Erro parseado corretamente
- **WHEN** o backend retorna um erro com body JSON no formato ErrorResponse
- **THEN** o `message` e extraido e exibido no toast

### Requirement: Toasts via React Toastify
O sistema SHALL usar React Toastify para exibir notificacoes de erro (tipo `error`, posicao `top-right`), sucesso (tipo `success`) e info (tipo `info`).

#### Scenario: Toast de erro
- **WHEN** uma operacao falha
- **THEN** um toast vermelho e exibido no canto superior direito

#### Scenario: Toast de sucesso
- **WHEN** uma mutacao (criar, editar, excluir) executa com sucesso
- **THEN** um toast verde e exibido com mensagem de confirmacao

### Requirement: ToastContainer no app
O sistema SHALL incluir `<ToastContainer />` do React Toastify no `main.tsx`, com import do CSS do React Toastify.

#### Scenario: Container presente
- **WHEN** o app renderiza
- **THEN** o ToastContainer esta no DOM para exibir toasts

#### Scenario: CSS importado
- **WHEN** o app renderiza
- **THEN** o CSS do React Toastify esta carregado e os toasts tem estilizacao correta
