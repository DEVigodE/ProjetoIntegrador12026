# UI Components

Componentes genericos reutilizaveis da biblioteca interna de UI.

## Requirements

### Requirement: Button
O sistema SHALL ter um componente `Button` reutilizavel com variantes (primary, secondary, danger), tamanhos (sm, md, lg), estado loading com spinner e suporte a `disabled`.

#### Scenario: Botao primario
- **WHEN** renderizar `<Button variant="primary">Salvar</Button>`
- **THEN** o botao e exibido com fundo `bg-primary-500`, texto branco e hover `bg-primary-600`

#### Scenario: Botao em loading
- **WHEN** renderizar `<Button loading>Salvando</Button>`
- **THEN** o botao exibe um spinner e fica desabilitado

### Requirement: Input
O sistema SHALL ter um componente `Input` com label, placeholder, mensagem de erro e integracao com React Hook Form.

#### Scenario: Input com erro de validacao
- **WHEN** renderizar `<Input error="Campo obrigatorio" />`
- **THEN** o input exibe borda vermelha e a mensagem de erro abaixo

### Requirement: Select
O sistema SHALL ter um componente `Select` com label, opcoes, placeholder e integracao com React Hook Form.

#### Scenario: Select com opcoes
- **WHEN** renderizar `<Select options={[{value: '1', label: 'Cat 1'}]} />`
- **THEN** o select exibe as opcoes no dropdown

### Requirement: Modal
O sistema SHALL ter um componente `Modal` com overlay, titulo, conteudo e botoes de acao. O modal SHALL fechar ao clicar no overlay ou no botao de fechar.

#### Scenario: Modal aberto
- **WHEN** a prop `isOpen` for `true`
- **THEN** o modal e exibido com overlay escuro e conteudo centralizado

#### Scenario: Fechar modal pelo overlay
- **WHEN** o usuario clica no overlay (fora do conteudo)
- **THEN** o modal fecha

### Requirement: Badge
O sistema SHALL ter um componente `Badge` com variantes de cor (green, yellow, blue, red, gray) para indicar status.

#### Scenario: Badge verde
- **WHEN** renderizar `<Badge variant="green">Ativo</Badge>`
- **THEN** o badge e exibido com fundo verde claro e texto verde escuro

### Requirement: Spinner
O sistema SHALL ter um componente `Spinner` para indicar carregamento, com tamanhos configuráveis.

#### Scenario: Spinner exibido
- **WHEN** renderizar `<Spinner />`
- **THEN** um spinner animado e exibido

### Requirement: Table
O sistema SHALL ter um componente `Table` generico que aceita colunas e dados, com suporte a ordenacao e linhas clicaveis.

#### Scenario: Tabela com dados
- **WHEN** renderizar `<Table columns={cols} data={rows} />`
- **THEN** a tabela exibe as colunas como header e os dados como linhas

### Requirement: Pagination
O sistema SHALL ter um componente `Pagination` que exibe controles de pagina (anterior, proxima, numeros de pagina) e emite eventos de mudanca.

#### Scenario: Navegar para proxima pagina
- **WHEN** o usuario clica no botao "Proxima"
- **THEN** o callback `onPageChange` e chamado com o numero da proxima pagina

### Requirement: ConfirmDialog
O sistema SHALL ter um componente `ConfirmDialog` (modal de confirmacao) com titulo, mensagem e botoes "Confirmar"/"Cancelar" para acoes destrutivas.

#### Scenario: Confirmar exclusao
- **WHEN** o usuario clica em "Confirmar" no dialog
- **THEN** o callback `onConfirm` e executado

#### Scenario: Cancelar exclusao
- **WHEN** o usuario clica em "Cancelar"
- **THEN** o dialog fecha sem executar a acao

### Requirement: EmptyState
O sistema SHALL ter um componente `EmptyState` para exibir quando uma lista nao tem dados, com icone, titulo e descricao.

#### Scenario: Lista vazia
- **WHEN** uma tabela nao tem dados para exibir
- **THEN** o EmptyState e renderizado com mensagem como "Nenhum produto encontrado"

### Requirement: StatusBadge
O sistema SHALL ter um componente `StatusBadge` que mapeia status de pedido/entrega/entregador para cores e rotulos em portugues.

#### Scenario: Status PENDING
- **WHEN** renderizar `<StatusBadge status="PENDING" />`
- **THEN** exibe badge amarelo com texto "Pendente"

#### Scenario: Status DELIVERED
- **WHEN** renderizar `<StatusBadge status="DELIVERED" />`
- **THEN** exibe badge verde com texto "Entregue"

#### Scenario: Status CANCELLED
- **WHEN** renderizar `<StatusBadge status="CANCELLED" />`
- **THEN** exibe badge vermelho com texto "Cancelado"

### Requirement: OrderCard
O sistema SHALL ter um componente `OrderCard` que exibe um card compacto de pedido com numero, nome do cliente, valor total e tempo desde criacao.

#### Scenario: Card de pedido
- **WHEN** renderizar `<OrderCard order={order} />`
- **THEN** o card exibe numero do pedido, nome do cliente, valor total formatado em BRL e tempo relativo (ex: "ha 5 min")

### Requirement: AudioAlert
O sistema SHALL ter um componente `AudioAlert` que emite um som de alerta usando a Web Audio API quando ativado.

#### Scenario: Som de alerta tocado
- **WHEN** a prop `play` mudar para `true`
- **THEN** um som de notificacao e reproduzido via Web Audio API
