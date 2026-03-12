# Delivery Management

Gerenciamento de entregadores e entregas.

## Requirements

### Requirement: Listagem de entregadores
O sistema SHALL exibir em `CouriersPage` uma tabela de entregadores com colunas: Nome, Telefone, Veiculo, Status (AVAILABLE/BUSY/OFFLINE), Ativo.

#### Scenario: Tabela de entregadores
- **WHEN** o usuario acessa `/couriers`
- **THEN** a tabela exibe todos os entregadores com seus dados e status

### Requirement: Cadastro e edicao de entregador
O sistema SHALL ter um `CourierForm` em modal para criacao e edicao de entregadores com campos: nome, telefone, email, tipo de veiculo, placa.

#### Scenario: Criar entregador
- **WHEN** o usuario preenche o formulario e clica "Salvar"
- **THEN** `POST /api/couriers` e chamado e a tabela e atualizada

#### Scenario: Editar entregador
- **WHEN** o usuario clica em editar um entregador
- **THEN** o modal abre com os dados atuais preenchidos

### Requirement: Toggle ativo/inativo de entregador
O sistema SHALL permitir alternar o status ativo/inativo de um entregador.

#### Scenario: Desativar entregador
- **WHEN** o usuario desativa um entregador
- **THEN** o entregador e marcado como inativo e o toggle atualiza

### Requirement: CourierStatusBadge
O sistema SHALL exibir o status do entregador com cores:
- AVAILABLE: verde
- BUSY: amarelo
- OFFLINE: cinza

#### Scenario: Entregador disponivel
- **WHEN** um entregador tem status AVAILABLE
- **THEN** o badge verde "Disponivel" e exibido

#### Scenario: Entregador ocupado
- **WHEN** um entregador tem status BUSY
- **THEN** o badge amarelo "Ocupado" e exibido

### Requirement: Listagem de entregas ativas
O sistema SHALL exibir em `DeliveriesPage` uma tabela de entregas em andamento com colunas: Pedido, Entregador, Status, Atribuido em.

#### Scenario: Tabela de entregas
- **WHEN** o usuario acessa `/deliveries`
- **THEN** as entregas ativas sao exibidas com seus dados

### Requirement: Atribuir entregador a entrega
O sistema SHALL ter um `AssignCourierModal` que lista entregadores disponiveis (via `GET /api/couriers/available`) e permite atribuir um a uma entrega via `PATCH /api/deliveries/{id}/assign`.

#### Scenario: Atribuir entregador
- **WHEN** o usuario seleciona um entregador disponivel e confirma
- **THEN** `PATCH /api/deliveries/{id}/assign` e chamado e a entrega e atualizada

#### Scenario: Nenhum entregador disponivel
- **WHEN** nao ha entregadores com status AVAILABLE
- **THEN** o modal exibe mensagem "Nenhum entregador disponivel"

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
O sistema SHALL implementar os seguintes hooks:

| Hook | Metodo | Endpoint |
|---|---|---|
| `useCouriers` | GET | `/api/couriers` |
| `useAvailableCouriers` | GET | `/api/couriers/available` |
| `useCreateCourier` | POST | `/api/couriers` |
| `useUpdateCourier` | PUT | `/api/couriers/{id}` |
| `useDeliveries` | GET | `/api/deliveries/active` |
| `useCreateDelivery` | POST | `/api/deliveries` |
| `useAssignCourier` | PATCH | `/api/deliveries/{id}/assign` |

#### Scenario: Mutation invalida queries
- **WHEN** `useAssignCourier` executa com sucesso
- **THEN** as queries `useDeliveries` e `useCouriers` sao invalidadas

### Requirement: Tipos TypeScript de delivery
O sistema SHALL definir os tipos em `delivery.types.ts`:

```ts
type CourierStatus = 'AVAILABLE' | 'BUSY' | 'OFFLINE';
type DeliveryStatus = 'PENDING' | 'ASSIGNED' | 'PICKED_UP' | 'DELIVERED';
interface Courier { id: number; name: string; phone: string; email?: string; vehicleType?: string; vehiclePlate?: string; status: CourierStatus; active: boolean; }
interface Delivery { id: number; orderId: number; courier?: Courier; status: DeliveryStatus; assignedAt?: string; pickedUpAt?: string; deliveredAt?: string; createdAt: string; }
```

#### Scenario: Tipos espelham DTOs do backend
- **WHEN** o backend retorna um entregador via GET /api/couriers
- **THEN** a resposta e corretamente tipada como `Courier`
