# Delivery Backoffice - Backend

Backend do sistema Backoffice para Delivery de Alimentos, implementado com **Java 21**, **Spring Boot 4.0.3**, e arquitetura **Monolito Modular com DDD**.

## Pré-requisitos

- Java 21+
- Maven 3.9+
- Docker & Docker Compose

## Inicialização Rápida

### 1. Subir infraestrutura (PostgreSQL + Keycloak)

```bash
docker-compose up -d
```

Isso inicia:
- **PostgreSQL** na porta `5432` (banco `delivery_db`)
- **Keycloak** na porta `8080` (admin: `admin` / `admin`)

### 2. Configurar Keycloak

1. Acesse `http://localhost:8080` e faça login como `admin`/`admin`
2. Crie um Realm chamado `delivery-backoffice`
3. Crie um Client (tipo `confidential` ou `public`) para a aplicação
4. Crie as roles no Realm: `ADMIN`, `OPERATOR`, `DISPATCHER`
5. Crie usuários e atribua as roles

### 3. Executar a aplicação

```bash
./mvnw spring-boot:run
```

Ou com perfil de desenvolvimento:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

A aplicação estará disponível em `http://localhost:8081`.

### 4. Executar testes

```bash
./mvnw test
```

## Arquitetura

### Bounded Contexts

| Contexto         | Descrição                          | Schema PostgreSQL       |
|------------------|------------------------------------|------------------------|
| **Catalog**      | Produtos e categorias              | `catalog_schema`       |
| **Orders**       | Pedidos e itens                    | `orders_schema`        |
| **Delivery**     | Entregadores e entregas            | `delivery_schema`      |
| **Communication**| Chat em tempo real (WebSocket)     | `communication_schema` |
| **Reporting**    | Relatórios e dashboard (read-only) | Consulta cross-schema  |

### Eventos de Domínio (Spring Events)

| Evento                   | Produtor   | Consumidores                       |
|--------------------------|-----------|-------------------------------------|
| OrderCreatedEvent        | Orders    | Communication (cria chat)           |
| OrderAcceptedEvent       | Orders    | Catalog (estoque), Communication    |
| OrderStatusChangedEvent  | Orders    | Communication                       |
| DeliveryAssignedEvent    | Delivery  | Communication                       |
| DeliveryCompletedEvent   | Delivery  | Orders (marca entregue)             |

### Stack

- **Java 21** + **Spring Boot 4.0.3**
- **PostgreSQL 15** (único banco, múltiplos schemas)
- **Keycloak 24** (OAuth2 Resource Server)
- **WebSocket + STOMP** (chat em tempo real)
- **Flyway** (migrations)
- **Spring Events** (barramento interno)
- **Lombok** + **MapStruct**

## Endpoints REST

### Catálogo
- `GET /api/products` — Listar produtos (paginado)
- `GET /api/products/{id}` — Buscar produto
- `POST /api/products` — Criar produto
- `PUT /api/products/{id}` — Atualizar produto
- `DELETE /api/products/{id}` — Soft delete
- `PATCH /api/products/{id}/availability` — Toggle disponibilidade
- `GET /api/categories` — Listar categorias
- `POST /api/categories` — Criar categoria

### Pedidos
- `GET /api/orders` — Listar pedidos (paginado)
- `GET /api/orders/{id}` — Buscar pedido
- `POST /api/orders` — Criar pedido
- `GET /api/orders/active` — Pedidos ativos
- `PATCH /api/orders/{id}/accept` — Aceitar pedido
- `PATCH /api/orders/{id}/reject` — Recusar pedido
- `PATCH /api/orders/{id}/status` — Atualizar status

### Entregas
- `GET /api/couriers` — Listar entregadores
- `POST /api/couriers` — Cadastrar entregador
- `PUT /api/couriers/{id}` — Atualizar entregador
- `GET /api/couriers/available` — Entregadores disponíveis
- `POST /api/deliveries` — Criar entrega
- `PATCH /api/deliveries/{id}/assign` — Atribuir entregador
- `GET /api/deliveries/active` — Entregas ativas

### Chat
- `GET /api/chat/{orderId}/messages` — Histórico de mensagens
- `GET /api/chat/{orderId}` — Dados do canal

### Relatórios
- `GET /api/reports/sales` — Relatório de vendas
- `GET /api/reports/products/top-selling` — Mais vendidos
- `GET /api/reports/metrics` — Métricas gerais
- `GET /api/reports/dashboard` — Dashboard consolidado

### WebSocket (STOMP)
- **Conexão**: `ws://localhost:8081/ws`
- **Enviar**: `/app/chat/{orderId}/send`
- **Receber**: `/topic/chat/{orderId}`

## Roles

| Role       | Acesso                                     |
|------------|---------------------------------------------|
| ADMIN      | Acesso total                                |
| OPERATOR   | Pedidos, produtos, dashboard                |
| DISPATCHER | Entregas e entregadores                     |
