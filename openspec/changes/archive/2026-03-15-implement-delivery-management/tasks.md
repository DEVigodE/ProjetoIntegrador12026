## 1. Tipos e Utilitarios

- [x] 1.1 Criar `features/delivery/types/delivery.types.ts` com interfaces `Courier`, `Delivery` e tipos `CourierStatus`, `DeliveryStatus`
- [x] 1.2 Criar `src/utils/deliveryStatusLabel.ts` com funcoes de mapeamento para rotulos PT-BR e cores de badge

## 2. Hooks TanStack Query

- [x] 2.1 Criar `useCouriers` — GET `/api/couriers`
- [x] 2.2 Criar `useAvailableCouriers` — GET `/api/couriers/available`
- [x] 2.3 Criar `useCreateCourier` — POST `/api/couriers` com invalidacao de `['couriers']`
- [x] 2.4 Criar `useUpdateCourier` — PUT `/api/couriers/{id}` com invalidacao de `['couriers']`
- [x] 2.5 Criar `useDeliveries` — GET `/api/deliveries/active`
- [x] 2.6 Criar `useAssignCourier` — PATCH `/api/deliveries/{id}/assign` com invalidacao de `['deliveries']` e `['couriers']`

## 3. Componentes

- [x] 3.1 Criar `CourierStatusBadge` — badge colorido por CourierStatus
- [x] 3.2 Criar `CourierForm` — formulario com React Hook Form + Zod (nome, telefone, email, veiculo, placa)
- [x] 3.3 Criar `CourierTable` — tabela com nome, telefone, veiculo, status badge, toggle ativo, botao editar
- [x] 3.4 Criar `DeliveryTable` — tabela com pedido, entregador, status badge, data, botao atribuir
- [x] 3.5 Criar `AssignCourierModal` — modal listando entregadores disponiveis para selecao

## 4. Paginas

- [x] 4.1 Implementar `CouriersPage` — PageHeader, botao novo, CourierTable, modal CourierForm, loading/empty state
- [x] 4.2 Implementar `DeliveriesPage` — PageHeader, DeliveryTable, AssignCourierModal, loading/empty state
