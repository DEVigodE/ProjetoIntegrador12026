## Context

O frontend ja possui layout, componentes UI reutilizaveis e padroes estabelecidos nas features de catalogo e pedidos. As rotas `/couriers` e `/deliveries` estao definidas no App.tsx com `RoleGuard` para ADMIN e DISPATCHER. As paginas existem como stubs.

O backend expoe endpoints REST para entregadores (CRUD) e entregas (listagem ativa, criacao, atribuicao). Os enums corretos sao `CourierStatus: AVAILABLE | BUSY | OFFLINE` e `DeliveryStatus: PENDING | ASSIGNED | PICKED_UP | DELIVERED`.

## Goals / Non-Goals

**Goals:**
- CRUD de entregadores com formulario em modal e validacao Zod
- Toggle ativo/inativo de entregador
- Badge de status com cores semanticas
- Listagem de entregas ativas com dados do pedido e entregador
- Modal para atribuir entregador disponivel a uma entrega

**Non-Goals:**
- Rastreamento GPS de entregadores em tempo real
- Historico completo de entregas (apenas ativas)
- Metricas de desempenho de entregadores
- Edicao de status de entrega inline (feito via acoes no pedido)

## Decisions

### 1. CRUD de entregadores via modal (nao pagina separada)

O formulario de cadastro/edicao de entregador abre em modal sobre a `CouriersPage`, diferente do catalogo que usa pagina separada. Justificativa: formulario simples com poucos campos, nao justifica navegacao separada.

### 2. AssignCourierModal lista apenas entregadores disponiveis

O modal de atribuicao consome `GET /api/couriers/available` para mostrar apenas entregadores com status AVAILABLE. Se nenhum estiver disponivel, exibe mensagem informativa.

### 3. Utilitario de mapeamento para CourierStatus e DeliveryStatus

Similar ao `orderStatusLabel.ts`, criar funcoes de mapeamento para rotulos PT-BR e cores de badge para `CourierStatus` e `DeliveryStatus`.

### 4. Toggle ativo usa PATCH semantico

O toggle ativo/inativo usa `useUpdateCourier` (PUT) enviando o objeto completo com `active` invertido, consistente com a API REST do backend.

## Risks / Trade-offs

- **[Sem paginacao em entregadores]** → Tabela de entregadores nao usa paginacao server-side (lista completa via GET). Aceitavel para volume esperado (dezenas, nao milhares). Se crescer, adicionar paginacao.
- **[Entregas apenas ativas]** → `DeliveriesPage` mostra apenas entregas ativas. Historico pode ser necessario no futuro mas esta fora do escopo atual.
