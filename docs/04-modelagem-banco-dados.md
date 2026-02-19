# 🗄️ Modelagem de Banco de Dados

## 1. Introdução

Este documento apresenta a modelagem de dados para o sistema de Backoffice de Delivery, seguindo o padrão **Database per Service** da arquitetura de microsserviços.

---

## 2. Visão Geral dos Bancos de Dados

| **Serviço** | **Banco** | **Propósito** |
|-------------|-----------|---------------|
| keycloak | PostgreSQL | Usuários, roles e configurações (gerenciado pelo Keycloak) |
| product-service | PostgreSQL | Produtos, categorias e estoque |
| order-service | PostgreSQL | Pedidos e itens |
| delivery-service | PostgreSQL | Entregadores e entregas |
| chat-service | MongoDB | Mensagens em tempo real |
| report-service | PostgreSQL | Read replica para analytics |

**Nota**: O Keycloak gerencia seu próprio banco de dados. Não é necessário desenvolver schema personalizado para autenticação.

---

## 3. Keycloak Database

### 3.1 Considerações

O Keycloak gerencia seu próprio schema de banco de dados automaticamente. O schema inclui:

- **Realms**: Tenants isolados
- **Clients**: Aplicações que usam Keycloak
- **Users**: Usuários do sistema
- **Roles**: Papéis e permissões
- **Groups**: Grupos de usuários
- **Sessions**: Sessões ativas
- **Events**: Logs de auditoria

### 3.2 Configuração do Realm

Será criado um realm chamado `delivery-backoffice` com:

**Roles**:
- `ADMIN` - Acesso total ao sistema
- `OPERATOR` - Gerencia pedidos e produtos
- `DISPATCHER` - Gerencia entregas e entregadores

**Client**:
- **Client ID**: `backoffice-webapp`
- **Protocol**: openid-connect
- **Access Type**: public
- **Valid Redirect URIs**: `http://localhost:3000/*`, `https://backoffice.delivery.com/*`

### 3.3 Integração com Microsserviços

Os microsserviços não acessam diretamente o banco do Keycloak. A validação de tokens é feita através de:

1. **Validação local**: Verificação da assinatura JWT usando chave pública do Keycloak
2. **UserInfo endpoint**: (opcional) Para obter informações adicionais do usuário

---

## 4. Product Service Database

### 4.1 Modelo Conceitual

```
┌─────────────┐       ┌─────────────┐
│  Category   │───────│   Product   │
│             │  1:N  │             │
└─────────────┘       └─────────────┘
```

### 4.2 Modelo Lógico

#### **Tabela: categories**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| name | VARCHAR(100) | NOT NULL, UNIQUE | Nome da categoria |
| description | TEXT | | Descrição |
| active | BOOLEAN | NOT NULL, DEFAULT TRUE | Status ativo/inativo |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de criação |

#### **Tabela: products**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| category_id | BIGINT | FK(categories.id) | Referência à categoria |
| name | VARCHAR(255) | NOT NULL | Nome do produto |
| description | TEXT | | Descrição detalhada |
| price | DECIMAL(10,2) | NOT NULL | Preço unitário |
| image_url | VARCHAR(500) | | URL da imagem |
| available | BOOLEAN | NOT NULL, DEFAULT TRUE | Disponibilidade |
| stock_quantity | INTEGER | NOT NULL, DEFAULT 0 | Quantidade em estoque |
| min_stock_alert | INTEGER | NOT NULL, DEFAULT 10 | Alerta de estoque mínimo |
| deleted_at | TIMESTAMP | | Soft delete |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de criação |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de atualização |

### 4.3 Scripts DDL

```sql
-- Database: product_db

CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(500),
    available BOOLEAN NOT NULL DEFAULT TRUE,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    min_stock_alert INTEGER NOT NULL DEFAULT 10,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_available ON products(available);
CREATE INDEX idx_products_deleted_at ON products(deleted_at);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## 5. Order Service Database

### 5.1 Modelo Conceitual

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   Customer  │───────│    Order    │───────│  OrderItem  │
│             │  1:N  │             │  1:N  │             │
└─────────────┘       └──────┬──────┘       └─────────────┘
                             │
                             │ 1:N
                             │
                      ┌──────▼──────┐
                      │OrderStatus  │
                      │   History   │
                      └─────────────┘
```

### 5.2 Modelo Lógico

#### **Tabela: customers**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| name | VARCHAR(255) | NOT NULL | Nome do cliente |
| phone | VARCHAR(20) | NOT NULL | Telefone |
| email | VARCHAR(255) | | Email (opcional) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de criação |

#### **Tabela: addresses**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| customer_id | BIGINT | FK(customers.id), NOT NULL | Referência ao cliente |
| street | VARCHAR(255) | NOT NULL | Rua |
| number | VARCHAR(20) | NOT NULL | Número |
| complement | VARCHAR(100) | | Complemento |
| neighborhood | VARCHAR(100) | NOT NULL | Bairro |
| city | VARCHAR(100) | NOT NULL | Cidade |
| state | VARCHAR(2) | NOT NULL | Estado (UF) |
| zip_code | VARCHAR(10) | NOT NULL | CEP |
| latitude | DECIMAL(10,8) | | Latitude |
| longitude | DECIMAL(11,8) | | Longitude |

#### **Tabela: orders**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| order_number | VARCHAR(50) | NOT NULL, UNIQUE | Número do pedido (ex: ORD-001) |
| customer_id | BIGINT | FK(customers.id), NOT NULL | Referência ao cliente |
| address_id | BIGINT | FK(addresses.id), NOT NULL | Endereço de entrega |
| status | VARCHAR(30) | NOT NULL | Status atual (ENUM) |
| total_amount | DECIMAL(10,2) | NOT NULL | Valor total |
| payment_method | VARCHAR(30) | NOT NULL | Forma de pagamento |
| notes | TEXT | | Observações |
| rejected_reason | TEXT | | Motivo de recusa (se aplicável) |
| estimated_prep_time | INTEGER | | Tempo estimado (minutos) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de criação |
| accepted_at | TIMESTAMP | | Data de aceite |
| ready_at | TIMESTAMP | | Data que ficou pronto |
| dispatched_at | TIMESTAMP | | Data que saiu para entrega |
| delivered_at | TIMESTAMP | | Data de entrega |
| canceled_at | TIMESTAMP | | Data de cancelamento |

**Status possíveis**: `RECEIVED`, `ACCEPTED`, `IN_PREPARATION`, `READY`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELED`, `REJECTED`

#### **Tabela: order_items**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| order_id | BIGINT | FK(orders.id), NOT NULL | Referência ao pedido |
| product_id | BIGINT | NOT NULL | ID do produto (referência externa) |
| product_name | VARCHAR(255) | NOT NULL | Nome do produto (snapshot) |
| quantity | INTEGER | NOT NULL | Quantidade |
| unit_price | DECIMAL(10,2) | NOT NULL | Preço unitário (snapshot) |
| subtotal | DECIMAL(10,2) | NOT NULL | Subtotal (quantity * unit_price) |
| notes | TEXT | | Observações do item |

#### **Tabela: order_status_history**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| order_id | BIGINT | FK(orders.id), NOT NULL | Referência ao pedido |
| from_status | VARCHAR(30) | | Status anterior |
| to_status | VARCHAR(30) | NOT NULL | Novo status |
| changed_by | BIGINT | | ID do usuário que mudou |
| notes | TEXT | | Observações |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data da mudança |

### 5.3 Scripts DDL

```sql
-- Database: order_db

CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE addresses (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20) NOT NULL,
    complement VARCHAR(100),
    neighborhood VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8)
);

CREATE TYPE order_status_enum AS ENUM (
    'RECEIVED', 
    'ACCEPTED', 
    'IN_PREPARATION', 
    'READY', 
    'OUT_FOR_DELIVERY', 
    'DELIVERED', 
    'CANCELED', 
    'REJECTED'
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    address_id BIGINT NOT NULL REFERENCES addresses(id),
    status order_status_enum NOT NULL DEFAULT 'RECEIVED',
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_method VARCHAR(30) NOT NULL,
    notes TEXT,
    rejected_reason TEXT,
    estimated_prep_time INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    accepted_at TIMESTAMP,
    ready_at TIMESTAMP,
    dispatched_at TIMESTAMP,
    delivered_at TIMESTAMP,
    canceled_at TIMESTAMP
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    notes TEXT
);

CREATE TABLE order_status_history (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status order_status_enum,
    to_status order_status_enum NOT NULL,
    changed_by BIGINT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_addresses_customer_id ON addresses(customer_id);

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'ORD-' || TO_CHAR(NEW.created_at, 'YYYYMMDD') || '-' || LPAD(NEW.id::TEXT, 6, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number BEFORE INSERT ON orders
FOR EACH ROW EXECUTE FUNCTION generate_order_number();
```

---

## 6. Delivery Service Database

### 6.1 Modelo Conceitual

```
┌─────────────┐       ┌─────────────┐
│DeliveryPerson│──────│  Delivery   │
│             │  1:N  │             │
└─────────────┘       └─────────────┘
```

### 6.2 Modelo Lógico

#### **Tabela: delivery_persons**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| name | VARCHAR(255) | NOT NULL | Nome do entregador |
| phone | VARCHAR(20) | NOT NULL, UNIQUE | Telefone |
| vehicle_type | VARCHAR(30) | NOT NULL | Tipo de veículo (MOTORCYCLE, CAR, BICYCLE) |
| vehicle_plate | VARCHAR(20) | | Placa do veículo |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'AVAILABLE' | Status (AVAILABLE, BUSY, OFFLINE) |
| active | BOOLEAN | NOT NULL, DEFAULT TRUE | Status ativo/inativo |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de cadastro |

#### **Tabela: deliveries**

| **Campo** | **Tipo** | **Restrições** | **Descrição** |
|-----------|----------|----------------|---------------|
| id | BIGSERIAL | PK | Identificador único |
| order_id | BIGINT | NOT NULL, UNIQUE | ID do pedido (referência externa) |
| delivery_person_id | BIGINT | FK(delivery_persons.id) | Referência ao entregador |
| status | VARCHAR(30) | NOT NULL | Status da entrega |
| assigned_at | TIMESTAMP | | Data de atribuição |
| picked_up_at | TIMESTAMP | | Data de retirada |
| delivered_at | TIMESTAMP | | Data de entrega |
| delivery_time_minutes | INTEGER | | Tempo total de entrega |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data de criação |

### 6.3 Scripts DDL

```sql
-- Database: delivery_db

CREATE TYPE vehicle_type_enum AS ENUM ('MOTORCYCLE', 'CAR', 'BICYCLE');
CREATE TYPE delivery_person_status_enum AS ENUM ('AVAILABLE', 'BUSY', 'OFFLINE');
CREATE TYPE delivery_status_enum AS ENUM ('PENDING', 'ASSIGNED', 'PICKED_UP', 'DELIVERED', 'FAILED');

CREATE TABLE delivery_persons (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type vehicle_type_enum NOT NULL,
    vehicle_plate VARCHAR(20),
    status delivery_person_status_enum NOT NULL DEFAULT 'AVAILABLE',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE deliveries (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    delivery_person_id BIGINT REFERENCES delivery_persons(id),
    status delivery_status_enum NOT NULL DEFAULT 'PENDING',
    assigned_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    delivery_time_minutes INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_delivery_persons_status ON delivery_persons(status);
CREATE INDEX idx_deliveries_order_id ON deliveries(order_id);
CREATE INDEX idx_deliveries_delivery_person_id ON deliveries(delivery_person_id);
CREATE INDEX idx_deliveries_status ON deliveries(status);
```

---

## 7. Chat Service Database (MongoDB)

### 7.1 Modelo de Documento

**Collection: chats**

```json
{
  "_id": "ObjectId",
  "orderId": "123",
  "participants": [
    {
      "type": "STORE",
      "userId": "1",
      "name": "Loja ABC"
    },
    {
      "type": "CUSTOMER",
      "userId": "456",
      "name": "João Silva"
    },
    {
      "type": "DELIVERY_PERSON",
      "userId": "789",
      "name": "Carlos Entregador",
      "joinedAt": "2026-02-12T15:30:00Z"
    }
  ],
  "status": "ACTIVE",
  "createdAt": "2026-02-12T10:00:00Z",
  "lastMessageAt": "2026-02-12T15:45:00Z",
  "archivedAt": null
}
```

**Collection: messages**

```json
{
  "_id": "ObjectId",
  "chatId": "ObjectId (ref: chats._id)",
  "orderId": "123",
  "senderId": "1",
  "senderName": "Loja ABC",
  "senderType": "STORE",
  "content": "Seu pedido está sendo preparado!",
  "messageType": "TEXT",
  "metadata": {
    "isSystemMessage": false,
    "statusChange": null
  },
  "readBy": [
    {
      "userId": "456",
      "readAt": "2026-02-12T15:31:00Z"
    }
  ],
  "createdAt": "2026-02-12T15:30:00Z"
}
```

### 7.2 Indexes

```javascript
// chats collection
db.chats.createIndex({ "orderId": 1 }, { unique: true });
db.chats.createIndex({ "participants.userId": 1 });
db.chats.createIndex({ "lastMessageAt": -1 });

// messages collection
db.messages.createIndex({ "chatId": 1, "createdAt": -1 });
db.messages.createIndex({ "orderId": 1 });
db.messages.createIndex({ "senderId": 1 });
```

---

## 8. Diagrama Entidade-Relacionamento Consolidado

```
┌──────────────────────────────────────────────────────────────────┐
│                         KEYCLOAK                                  │
├──────────────────────────────────────────────────────────────────┤
│  Gerenciado automaticamente pelo Keycloak:                       │
│  - Realms (tenants)                                              │
│  - Users, Roles, Groups                                          │
│  - Clients (aplicações)                                          │
│  - Sessions, Tokens                                              │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                       PRODUCT SERVICE                             │
├──────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  1:N  ┌─────────┐                                 │
│  │ Category │───────│ Product │                                 │
│  └──────────┘       └─────────┘                                 │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                        ORDER SERVICE                              │
├──────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  1:N  ┌─────────┐                                 │
│  │ Customer │───────│ Address │                                 │
│  └────┬─────┘       └─────────┘                                 │
│       │ 1:N                │                                     │
│       │                    │                                     │
│  ┌────▼─────┐  1:N    ┌───▼──────┐                            │
│  │  Order   │─────────│OrderItem │                            │
│  └────┬─────┘         └──────────┘                            │
│       │ 1:N                                                     │
│  ┌────▼──────────────┐                                         │
│  │OrderStatusHistory│                                         │
│  └───────────────────┘                                         │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                      DELIVERY SERVICE                             │
├──────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  1:N  ┌──────────┐                           │
│  │DeliveryPerson│───────│ Delivery │                           │
│  └──────────────┘       └──────────┘                           │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                   CHAT SERVICE (MongoDB)                          │
├──────────────────────────────────────────────────────────────────┤
│  ┌───────┐  1:N  ┌──────────┐                                   │
│  │ Chat  │───────│ Message  │                                   │
│  └───────┘       └──────────┘                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 9. Estratégias de Dados

### 9.1 Soft Delete

Produtos e usuários usam **soft delete** (campo `deleted_at`) para preservar integridade referencial em dados históricos.

### 9.2 Data Denormalization

Em `order_items`, armazenamos o nome e preço do produto (snapshot) para evitar quebra de histórico se o produto for modificado.

### 9.3 Read Replica

Report Service usa **read replica** do banco de Orders para não impactar performance de escrita.

### 9.4 Caching

Product Service usa **Redis** para cache de produtos frequentemente acessados.

```java
@Cacheable(value = "products", key = "#id")
public Product findById(Long id) {
    return productRepository.findById(id)
        .orElseThrow(() -> new NotFoundException("Product not found"));
}
```

---

## 10. Backup e Recovery

### 10.1 Estratégia de Backup

- **Frequência**: Backups diários automáticos
- **Retenção**: 30 dias
- **Ferramenta**: pg_dump (PostgreSQL), mongodump (MongoDB)
- **Armazenamento**: S3 ou storage equivalente

### 10.2 Recovery Time Objective (RTO)

- **Objetivo**: 4 horas (ambiente acadêmico)

### 10.3 Recovery Point Objective (RPO)

- **Objetivo**: 24 horas (ambiente acadêmico)

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
