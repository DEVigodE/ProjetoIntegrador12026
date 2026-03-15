## Why

O backoffice nao possui telas de gerenciamento de entregadores e entregas. O despachante precisa cadastrar entregadores, acompanhar entregas ativas e atribuir entregadores a pedidos prontos para entrega — funcionalidades essenciais para a operacao de delivery.

## What Changes

- Implementar `CouriersPage` com tabela de entregadores, cadastro/edicao via modal, toggle ativo/inativo
- Implementar `DeliveriesPage` com tabela de entregas ativas e atribuicao de entregador
- Criar `AssignCourierModal` para selecionar entregador disponivel
- Criar `CourierForm` com validacao Zod para cadastro/edicao
- Criar `CourierStatusBadge` com cores por status (AVAILABLE/BUSY/OFFLINE)
- Implementar hooks TanStack Query para todas as operacoes de delivery
- Definir tipos TypeScript (`Courier`, `Delivery`, `CourierStatus`, `DeliveryStatus`)

## Capabilities

### New Capabilities
- `delivery`: Gerenciamento de entregadores (CRUD, toggle ativo) e entregas (listagem ativa, atribuicao de entregador)

### Modified Capabilities

## Impact

- **Codigo**: Novos arquivos em `src/features/delivery/` (pages, components, hooks, types)
- **Rotas**: Ativacao das rotas `/couriers` e `/deliveries` ja definidas no `App.tsx`
- **APIs consumidas**: `GET/POST/PUT /api/couriers`, `GET /api/couriers/available`, `GET /api/deliveries/active`, `POST /api/deliveries`, `PATCH /api/deliveries/{id}/assign`
- **Dependencias**: Nenhuma nova — usa componentes UI, TanStack Query, Zod, React Hook Form ja instalados
