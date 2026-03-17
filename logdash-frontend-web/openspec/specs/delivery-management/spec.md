# Delivery Management

Gerenciamento de entregadores e entregas.

## Requirements

### Requirement: Tipos TypeScript de delivery
O sistema SHALL definir os tipos em `features/delivery/types/delivery.types.ts`:
- `CourierStatus`: `'AVAILABLE' | 'BUSY' | 'OFFLINE'`
- `DeliveryStatus`: `'PENDING' | 'ASSIGNED' | 'PICKED_UP' | 'DELIVERED'`
- `Courier`: id, name, phone, email, vehicleType, vehiclePlate, status, active
- `Delivery`: id, orderId, courier, status, assignedAt, pickedUpAt, deliveredAt, createdAt

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna um entregador via `GET /api/couriers`
- **THEN** a resposta e corretamente tipada como `Courier`

### Requirement: Utilitario de mapeamento de status de delivery
O sistema SHALL implementar funcoes `getCourierStatusLabel`, `getCourierStatusColor`, `getDeliveryStatusLabel` e `getDeliveryStatusColor` em `src/utils/deliveryStatusLabel.ts`.

| CourierStatus | Rotulo | Cor |
|---|---|---|
| AVAILABLE | Disponivel | green |
| BUSY | Ocupado | yellow |
| OFFLINE | Offline | gray |

| DeliveryStatus | Rotulo | Cor |
|---|---|---|
| PENDING | Pendente | yellow |
| ASSIGNED | Atribuida | blue |
| PICKED_UP | Retirada | blue |
| DELIVERED | Entregue | green |

#### Scenario: CourierStatus BUSY mapeado
- **WHEN** um entregador tem status `BUSY`
- **THEN** o badge exibe "Ocupado" com cor amarela

### Requirement: Enums de Delivery (source of truth do backend)
O sistema SHALL usar os seguintes enums:
- **CourierStatus**: `AVAILABLE | BUSY | OFFLINE`
- **DeliveryStatus**: `PENDING | ASSIGNED | PICKED_UP | DELIVERED`

ATENCAO: O documento `PROMPT-AGENTE-FRONTEND.md` contem valores incorretos (IN_DELIVERY, IN_PROGRESS, COMPLETED, CANCELLED). Usar SEMPRE os valores acima.

#### Scenario: CourierStatus BUSY mapeado corretamente
- **WHEN** o backend retorna um entregador com status "BUSY"
- **THEN** o frontend exibe "Ocupado" (nao "Em Entrega")

#### Scenario: DeliveryStatus tem apenas 4 valores
- **WHEN** o frontend define o tipo DeliveryStatus
- **THEN** ele contem exatamente: PENDING, ASSIGNED, PICKED_UP, DELIVERED

### Requirement: Hooks TanStack Query para delivery
O sistema SHALL implementar os seguintes hooks em `features/delivery/hooks/`:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useCouriers` | GET | `/api/couriers` |
| `useAvailableCouriers` | GET | `/api/couriers/available` |
| `useCreateCourier` | POST | `/api/couriers` |
| `useUpdateCourier` | PUT | `/api/couriers/{id}` |
| `useDeliveries` | GET | `/api/deliveries/active` |
| `useAssignCourier` | PATCH | `/api/deliveries/{id}/assign` |

#### Scenario: Mutation invalida queries relacionadas
- **WHEN** `useAssignCourier` executa com sucesso
- **THEN** as queries `['deliveries']` e `['couriers']` sao invalidadas

#### Scenario: useCreateCourier invalida lista
- **WHEN** `useCreateCourier` executa com sucesso
- **THEN** a query `['couriers']` e invalidada

### Requirement: CourierStatusBadge
O sistema SHALL implementar `CourierStatusBadge` que exibe badge colorido baseado no `CourierStatus` do entregador.

#### Scenario: Entregador disponivel
- **WHEN** um entregador tem status AVAILABLE
- **THEN** badge verde "Disponivel" e exibido

#### Scenario: Entregador ocupado
- **WHEN** um entregador tem status BUSY
- **THEN** badge amarelo "Ocupado" e exibido

#### Scenario: Entregador offline
- **WHEN** um entregador tem status OFFLINE
- **THEN** badge cinza "Offline" e exibido

### Requirement: CourierForm em modal
O sistema SHALL implementar `CourierForm` com campos: nome (obrigatorio), telefone (obrigatorio), email, tipo de veiculo, placa. A validacao SHALL usar schema Zod via React Hook Form. O formulario SHALL abrir em modal para criacao e edicao.

#### Scenario: Criar entregador
- **WHEN** o usuario preenche o formulario e clica "Salvar"
- **THEN** `POST /api/couriers` e chamado e a tabela e atualizada com toast de sucesso

#### Scenario: Editar entregador
- **WHEN** o usuario clica em editar um entregador
- **THEN** o modal abre com os dados atuais preenchidos

#### Scenario: Validacao com Zod
- **WHEN** o usuario tenta salvar com nome vazio
- **THEN** mensagem de erro e exibida no campo

### Requirement: Tabela de entregadores
O sistema SHALL exibir em `CouriersPage` uma tabela (`CourierTable`) com colunas: Nome, Telefone, Veiculo, Status (CourierStatusBadge), Ativo (toggle), Acoes (editar). O toggle ativo/inativo SHALL atualizar via `useUpdateCourier`.

#### Scenario: Tabela exibe entregadores
- **WHEN** o usuario acessa `/couriers`
- **THEN** a tabela exibe todos os entregadores com seus dados

#### Scenario: Toggle ativo/inativo
- **WHEN** o usuario clica no toggle de ativo de um entregador
- **THEN** o entregador e atualizado e o toggle muda visualmente

### Requirement: Tabela de entregas ativas
O sistema SHALL exibir em `DeliveriesPage` uma tabela (`DeliveryTable`) com colunas: Pedido (#orderId), Entregador (nome ou "Nao atribuido"), Status (badge), Atribuido em (data formatada). Cada linha SHALL ter botao "Atribuir" ou "Reatribuir" que abre `AssignCourierModal`.

#### Scenario: Tabela de entregas
- **WHEN** o usuario acessa `/deliveries`
- **THEN** as entregas ativas sao exibidas com pedido, entregador e status

#### Scenario: Entrega sem entregador
- **WHEN** uma entrega nao tem entregador atribuido
- **THEN** a coluna exibe "Nao atribuido" e o botao diz "Atribuir"

### Requirement: AssignCourierModal
O sistema SHALL implementar `AssignCourierModal` que lista entregadores disponiveis via `useAvailableCouriers`. O usuario seleciona um entregador e confirma via `useAssignCourier`. Se nenhum entregador estiver disponivel, SHALL exibir mensagem informativa.

#### Scenario: Atribuir entregador
- **WHEN** o usuario seleciona um entregador disponivel e confirma
- **THEN** `PATCH /api/deliveries/{id}/assign` e chamado com `{ courierId }` e a tabela atualiza

#### Scenario: Nenhum entregador disponivel
- **WHEN** nao ha entregadores com status AVAILABLE
- **THEN** o modal exibe "Nenhum entregador disponivel no momento"

### Requirement: CouriersPage completa
O sistema SHALL implementar `CouriersPage` com PageHeader, botao "Novo Entregador", CourierTable e modal de CourierForm para criacao/edicao. Loading e empty state SHALL ser tratados.

#### Scenario: Pagina com entregadores
- **WHEN** o usuario acessa `/couriers`
- **THEN** a pagina exibe header, botao de novo e tabela de entregadores

#### Scenario: Estado vazio
- **WHEN** nao existem entregadores cadastrados
- **THEN** EmptyState e exibido com mensagem e botao para criar

### Requirement: DeliveriesPage completa
O sistema SHALL implementar `DeliveriesPage` com PageHeader, DeliveryTable e AssignCourierModal. Loading e empty state SHALL ser tratados.

#### Scenario: Pagina com entregas
- **WHEN** o usuario acessa `/deliveries`
- **THEN** a pagina exibe header e tabela de entregas ativas

#### Scenario: Estado vazio
- **WHEN** nao existem entregas ativas
- **THEN** EmptyState e exibido com mensagem informativa
