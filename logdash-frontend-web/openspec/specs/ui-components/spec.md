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

#### Scenario: Botao desabilitado
- **WHEN** renderizar `<Button disabled>Acao</Button>`
- **THEN** o botao fica visualmente opaco e nao responde a cliques

### Requirement: Input
O sistema SHALL ter um componente `Input` com label, placeholder, mensagem de erro e integracao com React Hook Form via `forwardRef`.

#### Scenario: Input com erro de validacao
- **WHEN** renderizar `<Input error="Campo obrigatorio" />`
- **THEN** o input exibe borda vermelha e a mensagem de erro abaixo

#### Scenario: Input com label
- **WHEN** renderizar `<Input label="Nome" />`
- **THEN** o input exibe a label acima do campo

### Requirement: Select
O sistema SHALL ter um componente `Select` com label, opcoes, placeholder e integracao com React Hook Form via `forwardRef`.

#### Scenario: Select com opcoes
- **WHEN** renderizar `<Select options={[{value: '1', label: 'Cat 1'}]} />`
- **THEN** o select exibe as opcoes no dropdown

#### Scenario: Select com placeholder
- **WHEN** renderizar `<Select placeholder="Selecione..." />`
- **THEN** o select exibe o placeholder como primeira opcao desabilitada

### Requirement: Modal
O sistema SHALL ter um componente `Modal` com overlay, titulo, conteudo e botoes de acao. O modal SHALL renderizar via `createPortal` e fechar ao clicar no overlay ou no botao de fechar.

#### Scenario: Modal aberto
- **WHEN** a prop `isOpen` for `true`
- **THEN** o modal e exibido com overlay escuro e conteudo centralizado

#### Scenario: Fechar modal pelo overlay
- **WHEN** o usuario clica no overlay (fora do conteudo)
- **THEN** o modal fecha via callback `onClose`

#### Scenario: Fechar modal pelo botao X
- **WHEN** o usuario clica no botao de fechar (X)
- **THEN** o modal fecha via callback `onClose`

### Requirement: Badge
O sistema SHALL ter um componente `Badge` com variantes de cor (green, yellow, blue, red, gray) para indicar status.

#### Scenario: Badge verde
- **WHEN** renderizar `<Badge variant="green">Ativo</Badge>`
- **THEN** o badge e exibido com fundo verde claro e texto verde escuro

#### Scenario: Badge vermelho
- **WHEN** renderizar `<Badge variant="red">Cancelado</Badge>`
- **THEN** o badge e exibido com fundo vermelho claro e texto vermelho escuro

### Requirement: Spinner
O sistema SHALL ter um componente `Spinner` para indicar carregamento, com tamanhos configuraveis (sm, md, lg).

#### Scenario: Spinner padrao
- **WHEN** renderizar `<Spinner />`
- **THEN** um spinner animado e exibido com tamanho medio

#### Scenario: Spinner pequeno
- **WHEN** renderizar `<Spinner size="sm" />`
- **THEN** um spinner animado menor e exibido

### Requirement: Table
O sistema SHALL ter um componente `Table<T>` generico que aceita colunas tipadas e dados, com suporte a ordenacao e linhas clicaveis.

#### Scenario: Tabela com dados
- **WHEN** renderizar `<Table columns={cols} data={rows} />`
- **THEN** a tabela exibe as colunas como header e os dados como linhas

#### Scenario: Tabela com ordenacao
- **WHEN** o usuario clica no header de uma coluna com `sortable: true`
- **THEN** os dados sao reordenados e o indicador de direcao e exibido

#### Scenario: Linha clicavel
- **WHEN** a prop `onRowClick` esta definida e o usuario clica numa linha
- **THEN** o callback e chamado com o item da linha

### Requirement: Pagination
O sistema SHALL ter um componente `Pagination` que exibe controles de pagina (anterior, proxima, numeros de pagina) e emite eventos de mudanca.

#### Scenario: Navegar para proxima pagina
- **WHEN** o usuario clica no botao "Proxima"
- **THEN** o callback `onPageChange` e chamado com o numero da proxima pagina

#### Scenario: Pagina atual destacada
- **WHEN** a pagina atual e 3
- **THEN** o numero 3 e exibido com estilo ativo (fundo primary-500)

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

#### Scenario: Status AVAILABLE (entregador)
- **WHEN** renderizar `<StatusBadge status="AVAILABLE" />`
- **THEN** exibe badge verde com texto "Disponivel"

#### Scenario: Status BUSY (entregador)
- **WHEN** renderizar `<StatusBadge status="BUSY" />`
- **THEN** exibe badge amarelo com texto "Ocupado"

### Requirement: OrderCard
O sistema SHALL ter um componente `OrderCard` que exibe um card compacto de pedido com numero, nome do cliente, valor total e tempo desde criacao.

#### Scenario: Card de pedido
- **WHEN** renderizar `<OrderCard order={order} />`
- **THEN** o card exibe numero do pedido, nome do cliente, valor total formatado em BRL e tempo relativo (ex: "ha 5 min")

#### Scenario: Card clicavel
- **WHEN** a prop `onClick` esta definida e o usuario clica no card
- **THEN** o callback e chamado com o pedido

### Requirement: AudioAlert
O sistema SHALL ter um componente `AudioAlert` que emite um som de alerta usando a Web Audio API quando ativado.

#### Scenario: Som de alerta tocado
- **WHEN** a prop `play` mudar para `true`
- **THEN** um som de notificacao e reproduzido via Web Audio API usando OscillatorNode

#### Scenario: Som nao toca quando desativado
- **WHEN** a prop `play` for `false`
- **THEN** nenhum som e reproduzido
