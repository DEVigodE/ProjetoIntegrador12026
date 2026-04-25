# Prompt para Agente AI — Criação do Backend

> Copie e cole tudo abaixo diretamente no agente AI.

---

## CONTEXTO DO PROJETO

Você é um engenheiro sênior Java/Spring Boot. Sua tarefa é criar **do zero** o backend completo de um sistema **Backoffice para Delivery de Alimentos**, seguindo rigorosamente a arquitetura e as decisões técnicas descritas abaixo.

---

## 1. VISÃO GERAL

**Sistema**: Backoffice administrativo para restaurantes gerenciarem operações de delivery.

**Estilo Arquitetural**: Monolito Modular com **Domain-Driven Design (DDD)** — NÃO microsserviços.

**Stack obrigatória**:

- Java 21
- Spring Boot 3.x
- Maven
- PostgreSQL 15+ (único banco de dados — transacional + chat)
- Keycloak 24 (autenticação — servidor externo, não desenvolver auth próprio)
- WebSocket + STOMP (chat em tempo real)
- Flyway (migrations)
- Spring Events (barramento de eventos interno — NÃO Kafka)
- Docker Compose (ambiente local)

---

## 2. ESTRUTURA DO PROJETO

### Localização do projeto

```
backend/logdash/
```

### Package base

```
com.delivery.backoffice
```

### Estrutura de pacotes (seguir EXATAMENTE)

```
com.delivery.backoffice/
├── Application.java

├── shared/
│   ├── domain/
│   │   ├── DomainEvent.java
│   │   └── ValueObject.java
│   ├── infrastructure/
│   │   ├── config/
│   │   │   ├── SecurityConfig.java
│   │   │   ├── WebSocketConfig.java
│   │   │   └── DatabaseConfig.java
│   │   └── event/
│   │       └── DomainEventPublisher.java
│   └── application/
│       └── exception/
│           └── GlobalExceptionHandler.java

├── catalog/                    # Bounded Context: Catálogo
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Product.java
│   │   │   ├── Category.java
│   │   │   └── Stock.java
│   │   ├── valueobject/
│   │   │   ├── Money.java
│   │   │   ├── ProductStatus.java
│   │   │   └── ProductImage.java
│   │   ├── event/
│   │   │   ├── ProductCreatedEvent.java
│   │   │   └── StockChangedEvent.java
│   │   ├── repository/
│   │   │   ├── ProductRepository.java
│   │   │   └── CategoryRepository.java
│   │   └── service/
│   │       └── ProductDomainService.java
│   ├── application/
│   │   ├── service/
│   │   │   └── ProductApplicationService.java
│   │   └── dto/
│   │       ├── ProductRequest.java
│   │       └── ProductResponse.java
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── ProductJpaRepository.java
│   │   │   └── ProductRepositoryImpl.java
│   │   └── listener/
│   │       └── CatalogEventListener.java
│   └── presentation/
│       └── controller/
│           └── ProductController.java

├── orders/                     # Bounded Context: Pedidos
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Order.java
│   │   │   └── OrderItem.java
│   │   ├── valueobject/
│   │   │   ├── OrderStatus.java
│   │   │   ├── CustomerInfo.java
│   │   │   └── Address.java
│   │   ├── event/
│   │   │   ├── OrderCreatedEvent.java
│   │   │   ├── OrderAcceptedEvent.java
│   │   │   ├── OrderRejectedEvent.java
│   │   │   └── OrderStatusChangedEvent.java
│   │   ├── repository/
│   │   │   └── OrderRepository.java
│   │   └── service/
│   │       └── OrderDomainService.java
│   ├── application/
│   │   ├── service/
│   │   │   └── OrderApplicationService.java
│   │   └── dto/
│   │       ├── CreateOrderRequest.java
│   │       ├── OrderResponse.java
│   │       └── RejectOrderRequest.java
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── OrderJpaRepository.java
│   │   │   └── OrderRepositoryImpl.java
│   │   └── listener/
│   │       └── OrderEventListener.java
│   └── presentation/
│       └── controller/
│           └── OrderController.java

├── delivery/                   # Bounded Context: Entregas
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Courier.java
│   │   │   └── Delivery.java
│   │   ├── valueobject/
│   │   │   ├── Vehicle.java
│   │   │   ├── Location.java
│   │   │   ├── DeliveryStatus.java
│   │   │   └── CourierStatus.java
│   │   ├── event/
│   │   │   ├── CourierRegisteredEvent.java
│   │   │   ├── DeliveryAssignedEvent.java
│   │   │   └── DeliveryCompletedEvent.java
│   │   ├── repository/
│   │   │   ├── CourierRepository.java
│   │   │   └── DeliveryRepository.java
│   │   └── service/
│   │       └── DeliveryDomainService.java
│   ├── application/
│   │   ├── service/
│   │   │   └── DeliveryApplicationService.java
│   │   └── dto/
│   │       ├── CourierRequest.java
│   │       ├── CourierResponse.java
│   │       ├── CreateDeliveryRequest.java
│   │       └── DeliveryResponse.java
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── CourierJpaRepository.java
│   │   │   ├── CourierRepositoryImpl.java
│   │   │   ├── DeliveryJpaRepository.java
│   │   │   └── DeliveryRepositoryImpl.java
│   │   └── listener/
│   │       └── DeliveryEventListener.java
│   └── presentation/
│       └── controller/
│           ├── CourierController.java
│           └── DeliveryController.java

├── communication/              # Bounded Context: Chat em Tempo Real
│   ├── domain/
│   │   ├── model/
│   │   │   ├── ChatChannel.java
│   │   │   └── Message.java
│   │   ├── valueobject/
│   │   │   ├── ParticipantType.java
│   │   │   ├── MessageStatus.java
│   │   │   └── Participant.java
│   │   ├── event/
│   │   │   ├── ChatChannelCreatedEvent.java
│   │   │   └── MessageSentEvent.java
│   │   ├── repository/
│   │   │   ├── ChatChannelRepository.java
│   │   │   └── MessageRepository.java
│   │   └── service/
│   │       └── ChatDomainService.java
│   ├── application/
│   │   ├── service/
│   │   │   └── ChatApplicationService.java
│   │   └── dto/
│   │       ├── SendMessageRequest.java
│   │       └── MessageResponse.java
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── ChatChannelJpaRepository.java
│   │   │   ├── ChatChannelRepositoryImpl.java
│   │   │   ├── MessageJpaRepository.java
│   │   │   └── MessageRepositoryImpl.java
│   │   └── listener/
│   │       └── CommunicationEventListener.java
│   └── presentation/
│       ├── controller/
│       │   └── ChatController.java
│       └── websocket/
│           └── ChatWebSocketController.java

└── reporting/                  # Bounded Context: Relatórios (CQRS - Read Only)
    ├── domain/
    │   └── model/
    │       └── SalesReport.java
    ├── application/
    │   ├── service/
    │   │   └── ReportingApplicationService.java
    │   └── dto/
    │       ├── SalesReportResponse.java
    │       └── DashboardResponse.java
    ├── infrastructure/
    │   └── persistence/
    │       └── ReportingRepository.java
    └── presentation/
        └── controller/
            └── ReportingController.java
```

---

## 3. BANCO DE DADOS

### PostgreSQL — Schemas

#### **catalog_schema**

```sql
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
```

#### **orders_schema**

```sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    delivery_street VARCHAR(255),
    delivery_number VARCHAR(20),
    delivery_complement VARCHAR(100),
    delivery_neighborhood VARCHAR(100),
    delivery_city VARCHAR(100),
    delivery_state VARCHAR(2),
    delivery_zip_code VARCHAR(10),
    total_amount DECIMAL(10,2) NOT NULL,
    notes TEXT,
    rejected_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    product_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal DECIMAL(10,2) NOT NULL,
    notes TEXT
);
```

#### **delivery_schema**

```sql
CREATE TABLE couriers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) UNIQUE,
    vehicle_type VARCHAR(50),
    vehicle_plate VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE deliveries (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    courier_id BIGINT REFERENCES couriers(id),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    assigned_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

#### **communication_schema**

```sql
CREATE TABLE chat_channels (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE chat_participants (
    id BIGSERIAL PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES chat_channels(id),
    participant_id VARCHAR(255) NOT NULL,
    participant_type VARCHAR(50) NOT NULL,  -- STORE, CUSTOMER, COURIER
    joined_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES chat_channels(id),
    order_id BIGINT NOT NULL,
    sender_id VARCHAR(255) NOT NULL,
    sender_type VARCHAR(50) NOT NULL,       -- STORE, CUSTOMER, COURIER, SYSTEM
    content TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT NOW(),
    read_at TIMESTAMP
);

CREATE INDEX idx_messages_channel_id ON messages(channel_id);
CREATE INDEX idx_messages_order_id ON messages(order_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
```

### Flyway Migrations

- `V1__create_catalog_schema.sql`
- `V2__create_orders_schema.sql`
- `V3__create_delivery_schema.sql`
- `V4__create_communication_schema.sql`

---

## 4. APIs REST (endpoints obrigatórios)

### Catalog Context

| Método | Endpoint | Descrição | Role |
|--------|----------|-----------|------|
| GET | `/api/products` | Listar produtos (paginado + filtros) | Autenticado |
| GET | `/api/products/{id}` | Buscar produto por ID | Autenticado |
| POST | `/api/products` | Criar produto | ADMIN, OPERATOR |
| PUT | `/api/products/{id}` | Atualizar produto | ADMIN, OPERATOR |
| DELETE | `/api/products/{id}` | Soft delete de produto | ADMIN |
| PATCH | `/api/products/{id}/availability` | Ativar/desativar produto | ADMIN, OPERATOR |
| GET | `/api/categories` | Listar categorias | Autenticado |
| POST | `/api/categories` | Criar categoria | ADMIN |

### Orders Context

| Método | Endpoint | Descrição | Role |
|--------|----------|-----------|------|
| GET | `/api/orders` | Listar pedidos (paginado + filtros por status/data) | Autenticado |
| GET | `/api/orders/{id}` | Buscar pedido | Autenticado |
| POST | `/api/orders` | Criar pedido | ADMIN, OPERATOR |
| GET | `/api/orders/active` | Pedidos ativos | Autenticado |
| PATCH | `/api/orders/{id}/accept` | Aceitar pedido | ADMIN, OPERATOR |
| PATCH | `/api/orders/{id}/reject` | Recusar pedido com motivo | ADMIN, OPERATOR |
| PATCH | `/api/orders/{id}/status` | Atualizar status | ADMIN, OPERATOR |

**Status do pedido (fluxo)**: `PENDING → ACCEPTED → PREPARING → READY → OUT_FOR_DELIVERY → DELIVERED → CANCELLED`

### Delivery Context

| Método | Endpoint | Descrição | Role |
|--------|----------|-----------|------|
| GET | `/api/couriers` | Listar entregadores | Autenticado |
| POST | `/api/couriers` | Cadastrar entregador | ADMIN, DISPATCHER |
| PUT | `/api/couriers/{id}` | Atualizar entregador | ADMIN, DISPATCHER |
| GET | `/api/couriers/available` | Entregadores disponíveis | Autenticado |
| POST | `/api/deliveries` | Criar entrega | ADMIN, DISPATCHER |
| PATCH | `/api/deliveries/{id}/assign` | Atribuir entregador | ADMIN, DISPATCHER |
| GET | `/api/deliveries/active` | Entregas ativas | Autenticado |

### Communication Context (REST)

| Método | Endpoint | Descrição | Role |
|--------|----------|-----------|------|
| GET | `/api/chat/{orderId}/messages` | Histórico de mensagens | Autenticado |
| GET | `/api/chat/{orderId}` | Dados do canal de chat | Autenticado |

### Reporting Context

| Método | Endpoint | Descrição | Role |
|--------|----------|-----------|------|
| GET | `/api/reports/sales` | Relatório de vendas por período | ADMIN |
| GET | `/api/reports/products/top-selling` | Produtos mais vendidos | ADMIN |
| GET | `/api/reports/metrics` | Métricas gerais | ADMIN |
| GET | `/api/reports/dashboard` | Dados consolidados do dashboard | ADMIN, OPERATOR |

---

## 5. WEBSOCKET / CHAT EM TEMPO REAL

**Protocolo**: WebSocket + STOMP

**Configuração**:

- Endpoint de conexão: `/ws`
- Message broker: `/topic` (para broadcast) e `/queue` (para usuário específico)
- Application destination prefix: `/app`

**Endpoints STOMP**:

- Enviar mensagem: `/app/chat/{orderId}/send` (recebido pelo backend)
- Receber mensagens: `/topic/chat/{orderId}` (broadcast para assinantes)

**Autenticação**: JWT token enviado como parâmetro `token` na URL de conexão WebSocket ou no header `Authorization`.

**Fluxo**:

1. Cliente conecta em `/ws?token={jwtToken}`
2. Backend valida o JWT no handshake
3. Cliente assina `/topic/chat/{orderId}`
4. Ao enviar para `/app/chat/{orderId}/send`, o backend:
   - Valida permissão
   - Persiste no PostgreSQL (tabela `messages`)
   - Faz broadcast para `/topic/chat/{orderId}`

---

## 6. EVENTOS DE DOMÍNIO (Spring Events)

Use `ApplicationEventPublisher` e `@TransactionalEventListener`. **NÃO usar Kafka/RabbitMQ.**

### Eventos e seus consumidores

| Evento | Publicado por | Consumidor(es) |
|--------|--------------|----------------|
| `OrderCreatedEvent` | Orders Context | Communication Context (cria canal de chat) |
| `OrderAcceptedEvent` | Orders Context | Catalog Context (decrementa estoque), Communication Context (msg automática) |
| `OrderStatusChangedEvent` | Orders Context | Communication Context (msg automática de status), Reporting Context |
| `DeliveryAssignedEvent` | Delivery Context | Communication Context (adiciona entregador ao chat) |
| `DeliveryCompletedEvent` | Delivery Context | Orders Context (marca pedido como entregue), Reporting Context |
| `ProductCreatedEvent` | Catalog Context | Reporting Context |
| `StockChangedEvent` | Catalog Context | Reporting Context |

---

## 7. SEGURANÇA — KEYCLOAK

**Keycloak é externo**, rodando em container separado. O backend é um **OAuth2 Resource Server**.

### Configuração Spring Security

```yaml
# application.yml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/logdash
          jwk-set-uri: http://localhost:8080/realms/logdash/protocol/openid-connect/certs
```

### Roles (extraídas do JWT)

- `ADMIN` — acesso total
- `OPERATOR` — gerencia pedidos e produtos
- `DISPATCHER` — gerencia entregas e entregadores

### SecurityConfig

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(STATELESS))
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthConverter()))
            )
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/ws/**").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }

    private JwtAuthenticationConverter jwtAuthConverter() {
        // Extrair roles do claim "realm_access.roles" do token Keycloak
        JwtGrantedAuthoritiesConverter converter = new JwtGrantedAuthoritiesConverter();
        converter.setAuthoritiesClaimName("realm_access.roles");
        converter.setAuthorityPrefix("ROLE_");
        JwtAuthenticationConverter jwtConverter = new JwtAuthenticationConverter();
        jwtConverter.setJwtGrantedAuthoritiesConverter(converter);
        return jwtConverter;
    }
}
```

---

## 8. CONFIGURAÇÃO (application.yml)

```yaml
server:
  port: 8081

spring:
  application:
    name: logdash

  datasource:
    url: jdbc:postgresql://localhost:5432/delivery_db
    username: delivery_user
    password: delivery_pass
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        default_schema: public

  flyway:
    enabled: true
    locations: classpath:db/migration

  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/logdash
          jwk-set-uri: http://localhost:8080/realms/logdash/protocol/openid-connect/certs

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

---

## 9. DOCKER COMPOSE

Criar `docker-compose.yml` na raiz do projeto com os serviços:

```yaml
version: '3.8'

services:
  postgres-app:
    image: postgres:15
    container_name: delivery-postgres
    environment:
      POSTGRES_DB: delivery_db
      POSTGRES_USER: delivery_user
      POSTGRES_PASSWORD: delivery_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - delivery-network

  postgres-keycloak:
    image: postgres:15
    container_name: keycloak-db
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: keycloak_pass
    volumes:
      - keycloak-postgres-data:/var/lib/postgresql/data
    networks:
      - delivery-network

  keycloak:
    image: quay.io/keycloak/keycloak:24.0
    container_name: keycloak
    command: start-dev
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres-keycloak:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: keycloak_pass
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    ports:
      - "8080:8080"
    depends_on:
      - postgres-keycloak
    networks:
      - delivery-network

volumes:
  postgres-data:
  keycloak-postgres-data:

networks:
  delivery-network:
    driver: bridge
```

---

## 10. POM.XML — DEPENDÊNCIAS

```xml
<dependencies>
    <!-- Spring Boot -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-websocket</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>

    <!-- Database -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.flywaydb</groupId>
        <artifactId>flyway-core</artifactId>
    </dependency>
    <dependency>
        <groupId>org.flywaydb</groupId>
        <artifactId>flyway-database-postgresql</artifactId>
    </dependency>

    <!-- Utilities -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>1.5.5.Final</version>
    </dependency>

    <!-- Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

---

## 11. PADRÕES DE CÓDIGO OBRIGATÓRIOS

### Domain Model (Rich Domain — NÃO anêmico)

```java
@Entity
@Table(name = "orders")
public class Order extends AbstractAggregateRoot<Order> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    public void accept() {
        if (this.status != OrderStatus.PENDING) {
            throw new InvalidOrderStateException("Pedido não está pendente");
        }
        this.status = OrderStatus.ACCEPTED;
        registerEvent(new OrderAcceptedEvent(this.id));
    }

    public void reject(String reason) {
        if (this.status != OrderStatus.PENDING) {
            throw new InvalidOrderStateException("Pedido não pode ser recusado");
        }
        this.status = OrderStatus.CANCELLED;
        this.rejectedReason = reason;
        registerEvent(new OrderRejectedEvent(this.id, reason));
    }
}
```

### Application Service (orquestração + transação)

```java
@Service
@RequiredArgsConstructor
public class OrderApplicationService {

    private final OrderRepository orderRepository;

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        Order order = Order.create(request); // factory method no domínio
        orderRepository.save(order);         // evento publicado após commit
        return OrderResponse.from(order);
    }

    @Transactional
    public void acceptOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
        order.accept(); // regra de negócio no domínio
        orderRepository.save(order);
    }
}
```

### Controller (apenas HTTP — sem lógica)

```java
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderApplicationService orderService;

    @GetMapping
    public Page<OrderResponse> listOrders(
            @RequestParam(required = false) OrderStatus status,
            Pageable pageable) {
        return orderService.listOrders(status, pageable);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<OrderResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request) {
        return ResponseEntity.status(201).body(orderService.createOrder(request));
    }

    @PatchMapping("/{id}/accept")
    @PreAuthorize("hasAnyRole('ADMIN', 'OPERATOR')")
    public ResponseEntity<Void> acceptOrder(@PathVariable Long id) {
        orderService.acceptOrder(id);
        return ResponseEntity.ok().build();
    }
}
```

### Exception Handler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(OrderNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(OrderNotFoundException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
    }

    @ExceptionHandler(InvalidOrderStateException.class)
    public ResponseEntity<ErrorResponse> handleInvalidState(InvalidOrderStateException ex) {
        return ResponseEntity.status(422).body(new ErrorResponse("INVALID_STATE", ex.getMessage()));
    }
}
```

---

## 12. TESTES (obrigatórios)

Criar testes para cada bounded context:

1. **Testes de Domínio** (unitários, sem Spring):
   - `OrderTest.java` → testar `accept()`, `reject()`, invariantes
   - `ProductTest.java` → testar `decrementStock()`, disponibilidade
   - `CourierTest.java` → testar mudanças de status

2. **Testes de Application Service** (com mocks):
   - `OrderApplicationServiceTest.java`
   - `ProductApplicationServiceTest.java`

3. **Testes de Controller** (WebMvcTest):
   - `OrderControllerTest.java`
   - `ProductControllerTest.java`

4. **Testes de Integração** (com banco em memória ou Testcontainers):
   - `OrderIntegrationTest.java`

---

## 13. ORDEM DE IMPLEMENTAÇÃO

Implemente nesta ordem:

1. **Setup do projeto** — pom.xml, Application.java, application.yml, docker-compose.yml
2. **Shared** — DomainEvent, ValueObject, SecurityConfig, WebSocketConfig, GlobalExceptionHandler
3. **Flyway migrations** — V1, V2, V3 (DDL completo)
4. **Catalog Context** — completo (domínio → infra → controller)
5. **Orders Context** — completo (domínio → infra → controller)
6. **Delivery Context** — completo (domínio → infra → controller)
7. **Communication Context** — WebSocket + PostgreSQL (JPA) + REST
8. **Spring Events** — ligar os contextos via eventos
9. **Reporting Context** — queries de leitura
10. **Testes** — unitários e integração

---

## 14. RESTRIÇÕES E REGRAS

- **NÃO** criar microsserviços separados — tudo é uma aplicação Spring Boot
- **NÃO** criar auth-service próprio — o Keycloak cuida disso
- **NÃO** usar Kafka ou RabbitMQ — usar Spring Events (`ApplicationEventPublisher`)
- **NÃO** criar objetos de domínio anêmicos — comportamento fica nos agregados
- **NÃO** deixar lógica de negócio nos controllers
- **USAR** soft delete (`deleted_at`) nos produtos
- **USAR** `@TransactionalEventListener(phase = AFTER_COMMIT)` para eventos que precisam de consistência
- **USAR** paginação em todos os endpoints de listagem
- **USAR** DTOs separados de entidades de domínio
- **USAR** `@Valid` e Bean Validation em todos os requests
- **USAR** Lombok para reduzir boilerplate
- Todos os endpoints devem retornar respostas padronizadas com status HTTP corretos

---

## 15. ENTREGÁVEIS ESPERADOS

Ao finalizar, o projeto deve conter:

- [ ] `backend/logdash/pom.xml` — dependências completas
- [ ] `docker-compose.yml` — PostgreSQL, Keycloak
- [ ] `src/main/resources/application.yml` — configuração completa
- [ ] `src/main/resources/application-dev.yml` — perfil desenvolvimento
- [ ] `src/main/resources/db/migration/*.sql` — 4 migrations Flyway (V1 catalog, V2 orders, V3 delivery, V4 communication)
- [ ] Todos os bounded contexts implementados (catalog, orders, delivery, communication, reporting) — todos usando apenas PostgreSQL via JPA
- [ ] Shared: SecurityConfig, WebSocketConfig, GlobalExceptionHandler
- [ ] Testes unitários para domínio de cada contexto
- [ ] `README.md` dentro de `backend/logdash/` com instruções para rodar

---

Comece pelo **Setup do projeto** e implemente na ordem definida no item 13. Crie todos os arquivos necessários de forma funcional e compilável.
