# Error Handling

Tratamento centralizado de erros de API com toasts e interceptor Axios.

## Requirements

### Requirement: Interceptor de resposta Axios
O sistema SHALL ter um interceptor de resposta no Axios que trata erros HTTP globalmente, exibindo toasts com mensagens amigaveis.

#### Scenario: Erro 401 - nao autenticado
- **WHEN** o backend retorna 401
- **THEN** o sistema tenta refresh do token via Keycloak ou redireciona para login

#### Scenario: Erro 403 - acesso negado
- **WHEN** o backend retorna 403
- **THEN** um toast exibe "Acesso negado"

#### Scenario: Erro 404 - recurso nao encontrado
- **WHEN** o backend retorna 404
- **THEN** um toast exibe "Recurso nao encontrado"

#### Scenario: Erro 422 - estado invalido
- **WHEN** o backend retorna 422 com body `{ code: "INVALID_STATE", message: "Pedido ja foi aceito" }`
- **THEN** um toast exibe a mensagem do backend: "Pedido ja foi aceito"

#### Scenario: Erro 400 - validacao
- **WHEN** o backend retorna 400 com body `{ code: "VALIDATION_ERROR", message: "..." }`
- **THEN** um toast exibe a mensagem de validacao do backend

#### Scenario: Erro 500 - erro interno
- **WHEN** o backend retorna 500
- **THEN** um toast exibe "Erro interno do servidor"

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
O sistema SHALL incluir `<ToastContainer />` do React Toastify no `App.tsx` ou `main.tsx`.

#### Scenario: Container presente
- **WHEN** o app renderiza
- **THEN** o ToastContainer esta no DOM para exibir toasts
