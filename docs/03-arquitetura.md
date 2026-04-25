# 🏗️ Arquitetura do Sistema

## 1. Introdução

Este documento apresenta a arquitetura do sistema de Backoffice para Delivery, baseada em **Domain-Driven Design (DDD)** com arquitetura monolítica modular, com ênfase em manutenibilidade, clareza de domínio e separação de responsabilidades.

---

## 2. Visão Arquitetural

### 2.1 Estilo Arquitetural: Monolito Modular com DDD

**Justificativa Técnica:**
- **Simplicidade Operacional**: Deploy único, debugging mais fácil, menos complexidade
- **Consistência Transacional**: ACID garantido nativamente para operações entre contextos
- **Baixo Acoplamento**: Bounded Contexts isolados permitem evolução independente
- **Performance**: Comunicação in-process, sem overhead de rede
- **Manutenibilidade**: Código organizado por domínio facilita entendimento
- **Evolução Gradual**: Estrutura permite migração futura para microsserviços se necessário
- **Alinhamento Acadêmico**: Demonstra domínio de DDD, Clean Architecture e design patterns

---

## 3. Bounded Contexts (DDD)

### 3.1 Contextos Identificados

```
┌───────────────────────────────────────────────────────────────────────┐
│          DELIVERY BACKOFFICE - APLICAÇÃO MONOLÍTICA MODULAR           │
│                       Spring Boot 3.x Application                      │
│                                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                      BOUNDED CONTEXTS                            │ │
│  │                                                                  │ │
│  │   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │ │
│  │   │ Catalog  │  │  Orders  │  │ Delivery │  │   Chat   │      │ │
│  │   │ Context  │  │  Context │  │  Context │  │  Context │      │ │
│  │   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘      │ │
│  │        │             │             │              │            │ │
│  │        └─────────────┴─────────────┴──────────────┘            │ │
│  │                           │                                     │ │
│  │                    ┌──────▼──────┐                             │ │
│  │                    │  Reporting  │                             │ │
│  │                    │   Context   │                             │ │
│  │                    │ (Read Model)│                             │ │
│  │                    └─────────────┘                             │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │              SPRING EVENTS (Internal Event Bus)                  │ │
│  │  - ProductCreated, OrderAccepted, DeliveryAssigned, etc.        │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │                    DATA PERSISTENCE LAYER                        │ │
│  │                                                                  │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │          PostgreSQL (Single Database Instance)          │  │ │
│  │   │  - Schema: catalog, orders, delivery, communication,    │  │ │
│  │   │            reporting                                    │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │  Keycloak (External)  │
                    │  Identity & Access    │
                    └───────────────────────┘
```

#### **Catalog Context** (Contexto de Catálogo)
- **Responsabilidade**: Gestão do catálogo de produtos e estoque
- **Package**: `com.delivery.backoffice.catalog`
- **Aggregates**:
  - `Product` (root): Produto com nome, descrição, preço, imagens, disponibilidade
  - `Category`: Categoria de produtos
  - `Stock`: Controle de estoque por produto
- **Value Objects**: `Money`, `ProductImage`, `ProductStatus`, `StockQuantity`
- **Domain Events**: `ProductCreated`, `ProductUpdated`, `StockDecremented`, `StockIncremented`
- **APIs REST**:
  - `GET /api/products` - Listar produtos
  - `GET /api/products/{id}` - Buscar produto
  - `POST /api/products` - Criar produto
  - `PUT /api/products/{id}` - Atualizar produto
  - `DELETE /api/products/{id}` - Excluir produto
  - `PATCH /api/products/{id}/availability` - Alterar disponibilidade
  - `GET /api/categories` - Listar categorias

#### **Orders Context** (Contexto de Pedidos)
- **Responsabilidade**: Gestão do ciclo de vida completo de pedidos
- **Package**: `com.delivery.backoffice.orders`
- **Aggregates**:
  - `Order` (root): Pedido com status, itens, cliente, totais
  - `OrderItem`: Item individual do pedido
- **Value Objects**: `OrderStatus`, `CustomerInfo`, `Address`, `Money`, `OrderDate`
- **Domain Events**: `OrderCreated`, `OrderAccepted`, `OrderRejected`, `OrderStatusChanged`, `OrderCompleted`
- **APIs REST**:
  - `GET /api/orders` - Listar pedidos
  - `GET /api/orders/{id}` - Buscar pedido
  - `POST /api/orders` - Criar pedido
  - `PATCH /api/orders/{id}/accept` - Aceitar pedido
  - `PATCH /api/orders/{id}/reject` - Recusar pedido
  - `PATCH /api/orders/{id}/status` - Atualizar status
  - `GET /api/orders/active` - Pedidos ativos

#### **Delivery Context** (Contexto de Entregas)
- **Responsabilidade**: Gestão de entregadores e processos de entrega
- **Package**: `com.delivery.backoffice.delivery`
- **Aggregates**:
  - `Courier` (root): Entregador com dados, veículo, disponibilidade
  - `Delivery` (root): Entrega específica de um pedido
- **Value Objects**: `Vehicle`, `Location`, `DeliveryStatus`, `CourierStatus`
- **Domain Events**: `CourierRegistered`, `CourierActivated`, `DeliveryAssigned`, `DeliveryInProgress`, `DeliveryCompleted`
- **APIs REST**:
  - `GET /api/couriers` - Listar entregadores
  - `POST /api/couriers` - Cadastrar entregador
  - `GET /api/couriers/available` - Entregadores disponíveis
  - `POST /api/deliveries` - Criar entrega
  - `PATCH /api/deliveries/{id}/assign` - Atribuir entregador
  - `GET /api/deliveries/active` - Entregas ativas

#### **Communication Context** (Contexto de Comunicação)
- **Responsabilidade**: Mensagens e chat em tempo real
- **Package**: `com.delivery.backoffice.communication`
- **Aggregates**:
  - `ChatChannel` (root): Canal de chat relacionado a um pedido
  - `Message`: Mensagem individual com remetente, conteúdo, timestamp
- **Value Objects**: `ParticipantType`, `MessageStatus`, `Participant`
- **Domain Events**: `ChatChannelCreated`, `MessageSent`, `MessageRead`
- **Tecnologia**: WebSocket + STOMP, PostgreSQL (JPA) para persistir mensagens
- **Endpoints WebSocket**:
  - `WS /ws` - Conexão WebSocket
  - `/app/chat/{orderId}/send` - Enviar mensagem
  - `/topic/chat/{orderId}` - Tópico do chat por pedido
- **APIs REST**:
  - `GET /api/chat/{orderId}/messages` - Histórico de mensagens

#### **Reporting Context** (Contexto de Relatórios)
- **Responsabilidade**: Analytics, relatórios gerenciais e dashboards
- **Package**: `com.delivery.backoffice.reporting`
- **Padrão**: CQRS Read Model (apenas consultas)
- **Entities**: `SalesReport`, `StockReport`, `PerformanceMetrics`, `DashboardData`
- **Tecnologia**: PostgreSQL com Views Materializadas para performance
- **APIs REST**:
  - `GET /api/reports/sales` - Relatório de vendas
  - `GET /api/reports/products/top-selling` - Produtos mais vendidos
  - `GET /api/reports/metrics` - Métricas gerais
  - `GET /api/reports/dashboard` - Dados do dashboard

#### **Identity Context** (Contexto de Identidade - Externo)
- **Responsabilidade**: Autenticação, autorização, gestão de usuários
- **Tecnologia**: Keycloak (servidor externo)
- **Recursos**:
  - Autenticação OAuth 2.0 / OpenID Connect
  - Single Sign-On (SSO)
  - Gestão de usuários e roles
  - Identity Brokering (Google, Facebook, etc.)
- **Integração**: Spring Security OAuth2 Resource Server

---

## 4. Diagrama de Arquitetura Completo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            FRONTEND LAYER                               │
│                                                                         │
│    ┌──────────────────────────────────────────────────────────────┐     │
│    │              React Application (SPA)                         │     │
│    │   • Redux/Zustand (State Management)                         │     │
│    │   • Material-UI Components                                   │     │
│    │   • WebSocket Client (STOMP)                                 │     │
│    │   • Axios (HTTP Client)                                      │     │
│    └─────────────────────────┬────────────────────────────────────┘     │
└──────────────────────────────┼──────────────────────────────────────────┘
                               │ HTTPS / WSS (Secure)
                               │
┌──────────────────────────────▼──────────────────────────────────────────┐
│         SPRING BOOT 3.x APPLICATION (Monolito Modular DDD)              │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      PRESENTATION LAYER                            │ │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────────┐   │ │
│  │  │ Products   │ │  Orders    │ │ Deliveries │ │   Chat         │   │ │
│  │  │ REST APIs  │ │ REST APIs  │ │ REST APIs  │ │   WebSocket    │   │ │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────────    │ │
│  │       @RestController, @RequestMapping, @WebSocketHandler          │ │
│  └──────────────────────────────┬─────────────────────────────────────┘ │
│                                 │                                       │
│  ┌──────────────────────────────▼─────────────────────────────────────┐ │
│  │                   APPLICATION SERVICES LAYER                       │ │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────────┐   │ │
│  │  │ Product    │ │  Order     │ │ Delivery   │ │  Chat          │   │ │
│  │  │ Service    │ │  Service   │ │ Service    │ │  Service       │   │ │
│  │  └────────────┘ └────────────┘ └────────────┘ └────────────────┘   │ │
│  │    Use Cases, Application Logic, Transaction Orchestration         │ │
│  └──────────────────────────────┬─────────────────────────────────────┘ │
│                                 │                                       │
│  ┌──────────────────────────────▼─────────────────────────────────────┐ │
│  │                         DOMAIN LAYER                               │ │
│  │  ┌─────────────────────────────────────────────────────────────┐   │ │
│  │  │              BOUNDED CONTEXTS (DDD)                         │   │ │
│  │  │                                                             │   │ │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │   │ │
│  │  │  │ Catalog  │  │  Orders  │  │ Delivery │  │   Chat   │     │   │ │
│  │  │  │ Context  │  │  Context │  │  Context │  │  Context │     │   │ │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │   │ │
│  │  │                                                             │   │ │
│  │  │  Aggregates, Entities, Value Objects, Domain Events         │   │ │
│  │  │  Business Rules & Invariants                                │   │ │
│  │  │                                                             │   │ │
│  │  │             ┌─────────────────────────────┐                 │   │ │
│  │  │             │   Reporting Context (CQRS)  │                 │   │ │
│  │  │             │      Read Model Only        │                 │   │ │
│  │  │             └─────────────────────────────┘                 │   │ │
│  │  └─────────────────────────────────────────────────────────────┘   │ │
│  └──────────────────────────────┬─────────────────────────────────────┘ │
│                                 │                                       │
│  ┌──────────────────────────────▼─────────────────────────────────────┐ │
│  │                     INFRASTRUCTURE LAYER                           │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐  │ │
│  │  │              Repository Implementations                      │  │ │
│  │  │  • JPA Repositories (PostgreSQL — todos os contextos)         │  │ │
│  │  └──────────────────────────────────────────────────────────────┘  │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐  │ │
│  │  │            Spring Events (Internal Event Bus)                │  │ │
│  │  │  • @EventListener, @TransactionalEventListener               │  │ │
│  │  │  • ProductCreated, OrderAccepted, DeliveryAssigned...        │  │ │
│  │  └──────────────────────────────────────────────────────────────┘  │ │
│  │                                                                    │ │
│  │  ┌──────────────────────────────────────────────────────────────┐  │ │
│  │  │                   Security Layer                             │  │ │
│  │  │  • Spring Security + OAuth2 Resource Server                  │  │ │
│  │  │  • JWT Token Validation                                      │  │ │
│  │  │  • Method-level Security (@PreAuthorize)                     │  │ │
│  │  └──────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────────────┐
│                          DATABASE LAYER                                 │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │           PostgreSQL 15+ (Single Database Instance)            │     │
│  │                                                                │     │
│  │   Schemas (Logical Separation):                                │     │
│  │   • catalog_schema        - Products, Categories, Stock        │     │
│  │   • orders_schema         - Orders, Order Items                │     │
│  │   • delivery_schema       - Couriers, Deliveries               │     │
│  │   • communication_schema  - Chat Channels, Participants, Msgs  │     │
│  │   • reporting_schema      - Materialized Views, Analytics      │     │
│  └────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         EXTERNAL SYSTEMS                                │
│                                                                         │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │              Keycloak (Identity Provider)                      │     │
│  │   • OAuth 2.0 / OpenID Connect                                 │     │
│  │   • User Management & Roles                                    │     │
│  │   • External PostgreSQL Database                               │     │
│  └────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT & OBSERVABILITY                         │
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Docker     │  │  Prometheus  │  │   Grafana    │  │  ELK Stack   │ │
│  │  Containers  │  │  (Metrics)   │  │ (Dashboard)  │  │    (Logs)    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Camadas da Arquitetura DDD

#### **Presentation Layer (Camada de Apresentação)**
**Responsabilidade**: Expor APIs REST e WebSocket para o frontend

**Componentes**:
- **REST Controllers**: Endpoints HTTP para CRUD e operações de negócio
  - `@RestController`, `@RequestMapping`, `@GetMapping`, `@PostMapping`
  - Validação de entrada com Bean Validation (`@Valid`, `@NotNull`)
  - DTOs (Data Transfer Objects) para requests/responses
- **WebSocket Handlers**: Comunicação real-time para chat
  - `@MessageMapping`, `@SendTo`, STOMP protocol
  - Authentication via JWT em handshake
- **Exception Handlers**: Tratamento global de erros
  - `@ControllerAdvice`, `@ExceptionHandler`
  - Respostas padronizadas com status HTTP apropriados

**Princípios**:
- Nenhuma lógica de negócio
- Apenas validação de formato e autorização básica
- Converte DTOs ↔ Domain Objects

---

#### **Application Services Layer (Camada de Serviços de Aplicação)**
**Responsabilidade**: Orquestrar casos de uso e coordenar operações entre agregados

**Componentes**:
- **Application Services**: Classes anotadas com `@Service` ou `@UseCase`
  - Orquestram fluxos de negócio complexos
  - Gerenciam transações (`@Transactional`)
  - Coordenam múltiplos repositórios e agregados
  - Publicam domain events
- **Use Cases**: Implementação de casos de uso da aplicação
  - CreateOrderUseCase, AcceptOrderUseCase, AssignDeliveryUseCase
  - Input/Output ports (Ports & Adapters pattern)
- **DTOs e Mappers**: Conversão entre camadas
  - MapStruct ou implementação manual

**Exemplo**:
```java
@Service
public class OrderApplicationService {
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ApplicationEventPublisher eventPublisher;
    
    @Transactional
    public OrderDTO createOrder(CreateOrderRequest request) {
        // 1. Buscar produtos
        // 2. Validar estoque
        // 3. Criar agregado Order
        // 4. Persistir
        // 5. Publicar OrderCreatedEvent
    }
}
```

**Princípios**:
- Não contém regras de negócio (delegam para Domain Layer)
- Gerencia transações e persistência
- Coordena comunicação entre bounded contexts via events

---

#### **Domain Layer (Camada de Domínio)**
**Responsabilidade**: Implementar regras de negócio e lógica central do sistema

**Componentes**:
- **Aggregates**: Clusters de entidades tratadas como unidade
  - `Order` (root), `Product` (root), `Courier` (root)
  - Garantem invariantes de negócio
  - Controlam acesso às entidades internas
- **Entities**: Objetos com identidade única
  - `OrderItem`, `Message`, `Category`
- **Value Objects**: Objetos sem identidade, definidos por atributos
  - `Money`, `Address`, `OrderStatus`, `ProductImage`
  - Imutáveis e comparados por valor
- **Domain Events**: Fatos que ocorreram no domínio
  - `OrderCreatedEvent`, `ProductCreatedEvent`, `DeliveryAssignedEvent`
  - Desacoplam bounded contexts
- **Domain Services**: Lógica que não pertence a um agregado específico
  - `PricingService`, `DiscountCalculator`
- **Repositories (Interfaces)**: Contratos para persistência
  - Definidos no domínio, implementados na infraestrutura

**Exemplo**:
```java
@Entity
public class Order {
    @Id
    private OrderId id;
    private OrderStatus status;
    private List<OrderItem> items;
    
    // Regra de negócio no domínio
    public void acceptOrder() {
        if (status != OrderStatus.PENDING) {
            throw new InvalidOrderStateException();
        }
        this.status = OrderStatus.ACCEPTED;
        registerEvent(new OrderAcceptedEvent(this.id));
    }
}
```

**Princípios**:
- **Ubiquitous Language**: Linguagem compartilhada entre devs e domain experts
- **Rich Domain Model**: Objetos com comportamento, não anêmicos
- **Bounded Contexts**: Limites claros entre contextos de negócio
- Sem dependências de frameworks ou infraestrutura

---

#### **Infrastructure Layer (Camada de Infraestrutura)**
**Responsabilidade**: Implementar detalhes técnicos e integração com sistemas externos

**Componentes**:

**1. Repository Implementations**:
```java
@Repository
public class JpaOrderRepository implements OrderRepository {
    private final OrderJpaRepository jpaRepository;
    
    @Override
    public Order findById(OrderId id) {
        return jpaRepository.findById(id.getValue())
            .map(this::toDomain)
            .orElse(null);
    }
}
```

**2. Spring Events (Internal Event Bus)**:
- Substitui message broker (Kafka) em monolito
- Comunicação assíncrona entre bounded contexts
```java
@Component
public class OrderEventListener {
    @TransactionalEventListener
    public void onOrderAccepted(OrderAcceptedEvent event) {
        // Atualizar reporting, notificar chat, etc.
    }
}
```

**3. Security Layer**:
- Spring Security + OAuth2 Resource Server
- Validação de JWT tokens do Keycloak
- Method-level security com `@PreAuthorize`

**4. Configuration**:
- Configuração de datasource (PostgreSQL)
- Configuração de WebSocket, CORS, etc.
- Integration com Keycloak

**Princípios**:
- Implementa interfaces definidas no domínio
- Lida com persistência, messaging, segurança
- Pode usar frameworks sem contaminar o domínio

---

## 5. Comunicação Interna

### 5.1 Comunicação Síncrona (REST)

**Uso**: Operações que requerem resposta imediata entre frontend e backend

**Exemplo**: React App → Backend REST APIs

**Implementação**:
- **REST Controllers**: Endpoints HTTP para comunicação frontend-backend
- **Security**: Spring Security OAuth2 Resource Server
- **Token Validation**: JWT tokens validados contra Keycloak
- **Authorization**: Method-level security com `@PreAuthorize`

```java
// Configuração Spring Security com Keycloak
@Configuration
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt
                    .jwtAuthenticationConverter(jwtAuthConverter())
                )
            )
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            );
        return http.build();
    }
}
```

---

### 5.2 Comunicação Assíncrona (Event-Driven)

**Uso**: Comunicação interna entre bounded contexts sem acoplamento temporal

**Tecnologia**: Spring Events (ApplicationEventPublisher)

**Domain Events Principais**:
- `OrderCreatedEvent` - Pedido criado
- `OrderAcceptedEvent` - Pedido aceito
- `OrderStatusChangedEvent` - Status do pedido alterado
- `StockDecrementedEvent` - Estoque atualizado
- `DeliveryAssignedEvent` - Entrega atribuída

**Exemplo de Fluxo**:
1. Order Context aceita pedido
2. Order Aggregate publica `OrderAcceptedEvent` via ApplicationEventPublisher
3. Catalog Context consome evento e decrementa estoque
4. Chat Context consome evento e envia mensagem automática
5. Reporting Context consome evento e atualiza métricas

```java
// Publisher (Order Aggregate)
@Entity
public class Order extends AbstractAggregateRoot<Order> {
    
    public void acceptOrder() {
        if (this.status != OrderStatus.PENDING) {
            throw new InvalidOrderStateException();
        }
        this.status = OrderStatus.ACCEPTED;
        // Registra evento para ser publicado após commit da transação
        registerEvent(new OrderAcceptedEvent(this.id, this.customerId));
    }
}

// Service que persiste e publica
@Service
public class OrderApplicationService {
    private final OrderRepository orderRepository;
    
    @Transactional
    public void acceptOrder(OrderId orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
        
        order.acceptOrder();
        orderRepository.save(order); // Evento publicado após commit
    }
}

// Consumer (Catalog Context Event Listener)
@Component
public class CatalogEventListener {
    private final ProductRepository productRepository;
    
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleOrderAccepted(OrderAcceptedEvent event) {
        // Decrementa estoque dos produtos do pedido
        event.getOrderItems().forEach(item -> {
            Product product = productRepository.findById(item.getProductId())
                .orElseThrow();
            product.decrementStock(item.getQuantity());
            productRepository.save(product);
        });
    }
}

// Consumer (Chat Context Event Listener)
@Component
public class ChatEventListener {
    private final ChatService chatService;
    
    @EventListener
    public void handleOrderAccepted(OrderAcceptedEvent event) {
        // Envia mensagem automática no chat do pedido
        chatService.sendSystemMessage(
            event.getOrderId(),
            "Seu pedido foi aceito e está sendo preparado!"
        );
    }
}
```

**Características do Spring Events**:
- **In-process**: Comunicação dentro do mesmo processo (JVM)
- **Transactional**: `@TransactionalEventListener` garante consistência
- **Síncrono por padrão**: Pode ser assíncrono com `@Async`
- **Type-safe**: Usa objetos Java, não serialização
- **Simples**: Sem infraestrutura externa necessária
- **Performance**: Overhead mínimo comparado a message brokers

---

### 5.3 Comunicação em Tempo Real (WebSocket)

**Uso**: Chat em tempo real entre usuários e sistema

**Tecnologia**: WebSocket + STOMP (Simple Text Oriented Messaging Protocol)

**Fluxo**:
1. Cliente conecta via WebSocket ao backend através do endpoint `/ws`
2. Autenticação via JWT token no handshake
3. Cliente se inscreve no tópico `/topic/chat/{orderId}` para receber mensagens
4. Quando mensagem é enviada ao `/app/chat/{orderId}/send`:
   - Backend valida permissão do usuário
   - Salva mensagem no PostgreSQL via JPA
   - Publica para todos os clientes subscritos em `/topic/chat/{orderId}`
5. Todos os clientes conectados ao tópico recebem a mensagem instantaneamente

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Ativa broker in-memory para tópicos
        config.enableSimpleBroker("/topic");
        // Prefixo para destinos da aplicação
        config.setApplicationDestinationPrefixes("/app");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS(); // Fallback para navegadores sem WebSocket
    }
}

@Controller
public class ChatWebSocketController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;
    
    @MessageMapping("/chat/{orderId}/send")
    public void sendMessage(@DestinationVariable String orderId, 
                          ChatMessageDTO message,
                          Principal principal) {
        // Salva no PostgreSQL via JPA
        Message savedMessage = chatService.saveMessage(orderId, message, principal.getName());
        
        // Publica para todos os clientes subscritos
        messagingTemplate.convertAndSend(
            "/topic/chat/" + orderId, 
            savedMessage
        );
    }
}
```

**Características**:
- **In-memory broker**: Simple broker do Spring para aplicação monolítica
- **Bidirecional**: Cliente e servidor podem iniciar comunicação
- **Autenticação**: JWT token validado no handshake WebSocket
- **Persistência**: Mensagens salvas em PostgreSQL (JPA) para histórico
- **Escalável**: Para múltiplas instâncias, pode-se adicionar Redis broker futuramente

---

## 6. Estratégias de Resiliência

### 6.1 Tratamento de Exceções

Em um monolito, o tratamento de erros é mais direto com exception handling nativo:

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(ex.getMessage()));
    }
    
    @ExceptionHandler(BusinessRuleException.class)
    public ResponseEntity<ErrorResponse> handleBusinessRule(BusinessRuleException ex) {
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse(ex.getMessage()));
    }
}
```

### 6.2 Retry para Serviços Externos

Retries apenas para chamadas a serviços externos (ex: Keycloak):

```java
@Retry(name = "keycloak", maxAttempts = 3)
public UserInfo getUserInfo(String userId) {
    return keycloakClient.getUserInfo(userId);
}
```

### 6.3 Rate Limiting

Proteção contra sobrecarga usando Bucket4j:

```java
@Component
public class RateLimitInterceptor implements HandlerInterceptor {
    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                           HttpServletResponse response, 
                           Object handler) {
        String userId = request.getHeader("X-User-Id");
        Bucket bucket = resolveBucket(userId);
        
        if (bucket.tryConsume(1)) {
            return true;
        }
        response.setStatus(429); // Too Many Requests
        return false;
    }
    
    private Bucket resolveBucket(String userId) {
        return cache.computeIfAbsent(userId, k ->
            Bucket.builder()
                .addLimit(Bandwidth.simple(100, Duration.ofMinutes(1)))
                .build());
    }
}
```

### 6.4 Timeout

Timeouts para chamadas externas:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://keycloak:8080/realms/delivery
  
keycloak:
  connection-timeout: 5000
  read-timeout: 5000
```

---

## 7. Banco de Dados

### 7.1 Schema per Bounded Context Pattern

O monolito utiliza uma única instância PostgreSQL com schemas separados por bounded context, garantindo:
- **Isolamento Lógico**: Cada contexto possui seu próprio schema com tabelas isoladas
- **Simplicidade Operacional**: Uma única instância de banco para gerenciar
- **Separação de Responsabilidades**: Schemas refletem os bounded contexts do domínio
- **Performance**: Queries internas são mais rápidas que chamadas de rede entre serviços

### 7.2 Escolha de Tecnologias

| **Bounded Context** | **Banco de Dados** | **Justificativa** |
|---------------------|-------------------|-------------------|
| Catalog Context | PostgreSQL (schema: catalog) | Dados relacionais de produtos, categorias e estoque |
| Orders Context | PostgreSQL (schema: orders) | Transações ACID, integridade referencial de pedidos |
| Delivery Context | PostgreSQL (schema: delivery) | Dados relacionais de entregadores e entregas |
| Communication Context | PostgreSQL (schema: communication) | Dados relacionais de chat (canais, participantes, mensagens) com JPA |
| Reporting Context | PostgreSQL (schema: reporting) | Views materializadas para queries analíticas de leitura |
| Identity (Externo) | Keycloak (PostgreSQL próprio) | Gerenciado pelo próprio Keycloak |

### 7.3 Transações e Consistência

**Transações Locais (ACID)**
Para operações dentro do mesmo bounded context, usamos transações ACID nativas do PostgreSQL:
```java
@Transactional
public void createOrder(OrderRequest request) {
    Order order = orderRepository.save(new Order(request));
    orderItemRepository.saveAll(order.getItems());
} // Commit automático
```

**Consistência Entre Contextos (Domain Events)**
Para operações que envolvem múltiplos contextos, usamos eventos de domínio:

**Exemplo: Aceitar Pedido**
1. Orders Context aceita pedido (transação local)
2. Publica evento `OrderAccepted` via Spring Events
3. Catalog Context escuta evento e decrementa estoque (transação separada)
4. Se falhar: Catalog publica `StockDecrementFailed`, Orders compensa cancelando pedido

```java
// Orders Context
@Transactional
public void acceptOrder(Long orderId) {
    Order order = orderRepository.findById(orderId);
    order.accept();
    orderRepository.save(order);
    eventPublisher.publishEvent(new OrderAccepted(order)); // Evento assíncrono
}

// Catalog Context
@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void handleOrderAccepted(OrderAccepted event) {
    stockService.decrementStock(event.getOrderItems());
}
```

---

## 8. Segurança

### 8.1 Autenticação e Autorização

**Estratégia**: OAuth 2.0 / OpenID Connect com Keycloak

**Fluxo de Autenticação**:
1. Cliente faz login via Keycloak (Authorization Code Flow)
2. Keycloak retorna Access Token (JWT, 5 min) + Refresh Token (30 min) + ID Token
3. Cliente envia Access Token em todas as requisições (`Authorization: Bearer <token>`)
4. Aplicação Spring Boot valida token JWT localmente (verifica assinatura com chave pública do Keycloak)
5. Se válido, Spring Security extrai roles e autoriza acesso aos endpoints (`@PreAuthorize`)
6. Se expirado, cliente usa Refresh Token para obter novo Access Token

**Vantagens do Keycloak**:
- **Padrão de Mercado**: OAuth 2.0 / OpenID Connect
- **Reduz Complexidade**: Elimina necessidade de desenvolver auth-service
- **Recursos Prontos**: SSO, Identity Brokering, User Federation, Admin Console
- **Segurança**: Sistema maduro e amplamente testado
- **Extensível**: Suporta SPIs customizadas

```java
// JWT Token Structure (Keycloak)
{
  "exp": 1234568790,
  "iat": 1234567890,
  "jti": "abc-123",
  "iss": "http://keycloak:8080/realms/delivery",
  "sub": "uuid-user-123",
  "typ": "Bearer",
  "azp": "backoffice-client",
  "preferred_username": "user@example.com",
  "email": "user@example.com",
  "realm_access": {
    "roles": ["ADMIN", "OPERATOR"]
  },
  "resource_access": {
    "backoffice-client": {
      "roles": ["manage-orders", "view-reports"]
    }
  }
}
```

### 8.2 Comunicação Segura

- **Externa**: HTTPS (TLS 1.3)
- **Interna**: mTLS (mutual TLS) no Kubernetes (opcional)

### 8.3 Secrets Management

- **Desenvolvimento**: application.yml
- **Produção**: Kubernetes Secrets + HashiCorp Vault

---

## 9. Monitoramento e Observabilidade

### 9.1 Logs

- **Formato**: JSON estruturado
- **Ferramenta**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Biblioteca**: Logback com encoder JSON

```json
{
  "timestamp": "2026-02-12T10:30:00Z",
  "level": "INFO",
  "application": "logdash",
  "context": "orders",
  "traceId": "abc123",
  "userId": "user-456",
  "message": "Order accepted",
  "orderId": "ORD-001"
}
```

### 9.2 Métricas

- **Ferramenta**: Prometheus + Grafana
- **Instrumentação**: Micrometer (Spring Boot Actuator)
- **Métricas**:
  - Taxa de requisições
  - Latência (p50, p95, p99)
  - Taxa de erros
  - Uso de CPU/Memória

### 9.3 Request Tracing

- **Ferramenta**: Spring Boot Actuator + Micrometer Tracing
- **Propósito**: Rastrear requisições internas através dos bounded contexts
- **Implementação**: Trace ID propagado automaticamente via ThreadLocal

```java
// Automático com Micrometer
@Service
public class OrderService {
    private final Tracer tracer;
    
    public void processOrder(Long orderId) {
        Span span = tracer.nextSpan().name("process-order").start();
        try {
            // Lógica de negócio
            // Trace ID automaticamente incluído nos logs
        } finally {
            span.end();
        }
    }
}
```

---

## 10. Deploy e CI/CD

### 10.1 Pipeline

```
┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
│  Code  │───▶│  Build │───▶│  Test  │───▶│ Docker │───▶│ Deploy │
│ Commit │    │ (Maven)│    │ (JUnit)│    │  Image │    │  (K8s) │
└────────┘    └────────┘    └────────┘    └────────┘    └────────┘
```

### 10.2 Dockerfile Exemplo

```dockerfile
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/logdash.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 10.3 Docker Compose Exemplo

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: delivery
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  keycloak:
    image: quay.io/keycloak/keycloak:24.0
    command: start-dev
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin
    ports:
      - "8180:8080"

  logdash:
    build: .
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: production
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/delivery
      SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI: http://keycloak:8080/realms/delivery
    depends_on:
      - postgres
      - keycloak

volumes:
  postgres_data:
```

---

## 11. Escalabilidade

### 11.1 Vertical Scaling (Escalonamento Vertical)

Para um monolito, o escalonamento vertical é a abordagem mais direta:

```yaml
# Docker Compose
services:
  logdash:
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G
```

### 11.2 Horizontal Scaling (Múltiplas Instâncias)

O monolito é **stateless** e pode ter múltiplas instâncias com load balancer:

```yaml
# Docker Compose com replicação
services:
  logdash:
    build: .
    deploy:
      replicas: 3
    ports:
      - "8080-8082:8080"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - logdash
```

**nginx.conf (Load Balancer)**:
```nginx
upstream backend {
    server logdash-1:8080;
    server logdash-2:8080;
    server logdash-3:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### 11.3 Otimizações de Performance

- **Database Connection Pooling**: HikariCP (padrão do Spring Boot)
- **Caching**: Spring Cache com Caffeine para cache em memória
- **Async Processing**: `@Async` para operações não-bloqueantes
- **Database Indexing**: Índices apropriados nas queries mais frequentes

---

## 12. Justificativa Técnica das Escolhas

| **Decisão** | **Justificativa** | **Alternativas Consideradas** |
|-------------|-------------------|-------------------------------|
| **Monolito Modular DDD** | Simplicidade operacional, transações ACID, clareza de domínio, manutenibilidade, evolução gradual | Microserviços (mais complexo operacionalmente) |
| **Domain-Driven Design** | Organização por domínio de negócio, bounded contexts isolados, linguagem ubíqua, alinhamento acadêmico | Arquitetura em camadas tradicional |
| **Keycloak** | Padrão OAuth 2.0, SSO, recursos prontos, reduz desenvolvimento | Auth integrado no monolito (mais trabalho) |
| **Spring Boot 3.x** | Ecossistema maduro, produtividade, suporte nativo a DDD | Quarkus, Micronaut (menos material acadêmico) |
| **Spring Events** | Comunicação interna eficiente, transaction-aware, simplicidade | Event Store externo (complexidade desnecessária) |
| **WebSocket + STOMP** | Bidirecional, baixa latência, padrão da indústria | Server-Sent Events (unidirecional) |
| **PostgreSQL (schemas)** | ACID, schemas isolados por contexto, transações cross-schema | Bancos separados (overhead operacional) |
| **PostgreSQL para chat** | Banco único, ACID, sem overhead operacional extra, JPA nativo | MongoDB (complexidade adicional sem ganho real neste contexto) |
| **Docker Compose** | Simplicidade para deploy de monolito, fácil desenvolvimento local | Kubernetes (excesso de complexidade) |
| **React** | Componentização, ecossistema rico, demanda de mercado | Vue, Angular (menos adoção) |

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
