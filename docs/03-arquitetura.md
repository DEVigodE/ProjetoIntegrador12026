# 🏗️ Arquitetura do Sistema

## 1. Introdução

Este documento apresenta a arquitetura do sistema de Backoffice para Delivery, baseada em microsserviços, com ênfase em escalabilidade, manutenibilidade e comunicação em tempo real.

---

## 2. Visão Arquitetural

### 2.1 Estilo Arquitetural: Microsserviços

**Justificativa Técnica:**
- **Independência de Deploy**: Cada serviço pode ser implantado independentemente
- **Escalabilidade Granular**: Escalar apenas os serviços sob maior carga
- **Isolamento de Falhas**: Falha em um serviço não compromete todo o sistema
- **Diversidade Tecnológica**: Possibilidade de usar diferentes tecnologias por serviço
- **Desenvolvimento Paralelo**: Times podem trabalhar em serviços diferentes simultaneamente
- **Alinhamento Acadêmico**: Demonstra conhecimento de arquiteturas modernas e distribuídas

---

## 3. Decomposição em Microsserviços

### 3.1 Serviços Identificados

```
┌─────────────────────────────────────────────────────────────┐
│                     API GATEWAY                              │
│              (Spring Cloud Gateway)                          │
│                    + Keycloak Auth                           │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐       ┌─────▼──────┐     ┌─────▼──────┐
   │ Product │       │   Order    │     │ Delivery   │
   │ Service │       │  Service   │     │  Service   │
   └─────────┘       └────────────┘     └────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐       ┌─────▼──────┐     ┌─────▼──────┐
   │  Chat   │       │   Report   │     │  Keycloak  │
   │ Service │       │  Service   │     │   Server   │
   └─────────┘       └────────────┘     └────────────┘
```

#### **Keycloak** (Identity and Access Management)
- **Responsabilidade**: Autenticação, autorização, gestão de usuários, SSO
- **Tecnologias**: Keycloak (Red Hat), PostgreSQL
- **Recursos**:
  - Autenticação OAuth 2.0 / OpenID Connect
  - Single Sign-On (SSO)
  - Gestão de usuários e roles
  - Identity Brokering (Google, Facebook, etc.)
  - Multi-tenancy
- **Endpoints principais**:
  - `/realms/{realm}/protocol/openid-connect/token` - Obter token
  - `/realms/{realm}/protocol/openid-connect/userinfo` - Info do usuário
  - `/admin/realms/{realm}/users` - API de administração

#### **product-service** (Serviço de Produtos)
- **Responsabilidade**: CRUD de produtos, categorias, estoque
- **Tecnologias**: Spring Boot, Spring Data JPA, PostgreSQL, Redis (cache)
- **APIs**:
  - `GET /products` - Listar produtos
  - `GET /products/{id}` - Buscar produto
  - `POST /products` - Criar produto
  - `PUT /products/{id}` - Atualizar produto
  - `DELETE /products/{id}` - Excluir produto
  - `PATCH /products/{id}/availability` - Alterar disponibilidade
  - `PATCH /products/{id}/stock` - Atualizar estoque
  - `GET /categories` - Listar categorias

#### **order-service** (Serviço de Pedidos)
- **Responsabilidade**: Gestão completa de pedidos
- **Tecnologias**: Spring Boot, Spring Data JPA, PostgreSQL, Kafka Producer
- **APIs**:
  - `GET /orders` - Listar pedidos
  - `GET /orders/{id}` - Buscar pedido
  - `POST /orders` - Criar pedido (via integração)
  - `PATCH /orders/{id}/accept` - Aceitar pedido
  - `PATCH /orders/{id}/reject` - Recusar pedido
  - `PATCH /orders/{id}/status` - Atualizar status
  - `GET /orders/active` - Pedidos ativos em tempo real

#### **delivery-service** (Serviço de Entregas)
- **Responsabilidade**: Gestão de entregadores e entregas
- **Tecnologias**: Spring Boot, Spring Data JPA, PostgreSQL
- **APIs**:
  - `GET /delivery-persons` - Listar entregadores
  - `POST /delivery-persons` - Cadastrar entregador
  - `GET /delivery-persons/available` - Entregadores disponíveis
  - `POST /deliveries` - Criar entrega
  - `PATCH /deliveries/{id}/assign` - Atribuir entregador
  - `GET /deliveries/active` - Entregas ativas

#### **chat-service** (Serviço de Chat)
- **Responsabilidade**: Mensagens em tempo real
- **Tecnologias**: Spring Boot, WebSocket, STOMP, MongoDB, Redis PubSub
- **Protocolo**: WebSocket + STOMP
- **Endpoints**:
  - `WS /ws/chat` - Conexão WebSocket
  - `/app/chat.send` - Enviar mensagem
  - `/topic/chat/{orderId}` - Tópico do chat por pedido
  - `GET /chats/{orderId}/messages` - Histórico de mensagens

#### **report-service** (Serviço de Relatórios)
- **Responsabilidade**: Analytics, relatórios e dashboards
- **Tecnologias**: Spring Boot, PostgreSQL (read replica), ElasticSearch (opcional)
- **APIs**:
  - `GET /reports/sales` - Relatório de vendas
  - `GET /reports/products/top-selling` - Produtos mais vendidos
  - `GET /reports/metrics` - Métricas gerais
  - `GET /reports/stock` - Relatório de estoque

---

### 3.2 Serviços de Infraestrutura

#### **Eureka Server** (Service Discovery)
- **Função**: Registro e descoberta de serviços
- **Tecnologia**: Spring Cloud Netflix Eureka

#### **Config Server** (Configuração Centralizada)
- **Função**: Gerenciamento centralizado de configurações
- **Tecnologia**: Spring Cloud Config
- **Backend**: Git repository

#### **API Gateway**
- **Função**: Ponto único de entrada, roteamento, autenticação
- **Tecnologia**: Spring Cloud Gateway
- **Recursos**:
  - Rate Limiting
  - Load Balancing
  - JWT Validation
  - CORS Configuration

---

## 4. Diagrama de Arquitetura Completo

```
┌──────────────────────────────────────────────────────────────────┐
│                        FRONTEND LAYER                             │
│                                                                   │
│    ┌─────────────────────────────────────────────────┐          │
│    │          React Application (SPA)                 │          │
│    │   - Redux/Zustand (State Management)            │          │
│    │   - Material-UI / Ant Design                    │          │
│    │   - WebSocket Client                            │          │
│    │   - Axios (HTTP Client)                         │          │
│    └──────────────────┬──────────────────────────────┘          │
└───────────────────────┼───────────────────────────────────────────┘
                        │ HTTPS / WSS
                        │
┌───────────────────────▼───────────────────────────────────────────┐
│                      API GATEWAY LAYER                            │
│                                                                   │
│    ┌──────────────────────────────────────────────────┐         │
│    │       Spring Cloud Gateway                        │         │
│    │   - Authentication Filter                        │         │
│    │   - Rate Limiting                                │         │
│    │   - Load Balancing                               │         │
│    │   - Request/Response Logging                     │         │
│    └──────────────────┬───────────────────────────────┘         │
└───────────────────────┼───────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
┌───────▼────┐  ┌──────▼──────┐  ┌────▼──────┐
│  Eureka    │  │    Config   │  │   Kafka   │
│  Server    │  │    Server   │  │  Cluster  │
└────────────┘  └─────────────┘  └───────────┘
                                       │
┌──────────────────────────────────────┼────────────────────────────┐
│                   MICROSERVICES LAYER         │                    │
│                                              │                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──▼─────┐  ┌─────────┐│
│  │ Product │  │  Order  │  │ Delivery│  │  Chat  │  │ Report  ││
│  │ Service │  │ Service │  │ Service │  │ Service│  │ Service ││
│  └────┬────┘  └────┬────┘  └────┬────┘  └───┬────┘  └────┬────┘│
│       │            │            │            │            │     │
│  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌───▼────┐  ┌────▼────┐│
│  │   PG    │  │   PG    │  │   PG    │  │ MongoDB│  │   PG    ││
│  │   DB    │  │   DB    │  │   DB    │  │   +    │  │ Read DB ││
│  └─────────┘  └─────────┘  └─────────┘  │ Redis  │  └─────────┘│
│                                          └────────┘              │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │              Keycloak Server                         │        │
│  │  ┌──────────────────────────────────────┐          │        │
│  │  │        PostgreSQL (Keycloak DB)      │          │        │
│  │  └──────────────────────────────────────┘          │        │
│  └─────────────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────────────┘
                        │
┌───────────────────────▼───────────────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                             │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Kubernetes Cluster                       │       │
│  │   - Pods, Deployments, Services                      │       │
│  │   - Ingress Controller                               │       │
│  │   - ConfigMaps, Secrets                              │       │
│  │   - Persistent Volumes                               │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Docker     │  │  Monitoring  │  │    Logs      │          │
│  │   Registry   │  │  (Prometheus)│  │ (ELK Stack)  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└───────────────────────────────────────────────────────────────────┘
```

---

## 5. Comunicação entre Serviços

### 5.1 Comunicação Síncrona (REST)

**Uso**: Operações que requerem resposta imediata

**Exemplo**: Gateway → Keycloak (validação de token)

**Implementação**:
- **Client**: Spring Cloud OpenFeign
- **Circuit Breaker**: Resilience4j
- **Load Balancer**: Spring Cloud LoadBalancer
- **OAuth 2.0**: Spring Security OAuth2 Resource Server

```java
// Configuração Spring Security com Keycloak
@Configuration
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .oauth2ResourceServer()
            .jwt();
        return http.build();
    }
}
```

---

### 5.2 Comunicação Assíncrona (Event-Driven)

**Uso**: Eventos que não requerem resposta imediata

**Tecnologia**: Apache Kafka

**Tópicos Principais**:
- `order.created` - Pedido criado
- `order.accepted` - Pedido aceito
- `order.status.changed` - Status do pedido alterado
- `stock.updated` - Estoque atualizado
- `delivery.assigned` - Entrega atribuída

**Exemplo de Fluxo**:
1. Order Service aceita pedido
2. Order Service publica evento `order.accepted` no Kafka
3. Product Service consome evento e decrementa estoque
4. Chat Service consome evento e envia mensagem automática no chat
5. Report Service consome evento e atualiza métricas

```java
// Producer (Order Service)
@Service
public class OrderEventProducer {
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void publishOrderAccepted(Order order) {
        OrderEvent event = new OrderEvent(order.getId(), "ACCEPTED", order);
        kafkaTemplate.send("order.accepted", order.getId(), event);
    }
}

// Consumer (Product Service)
@Service
public class OrderEventConsumer {
    @KafkaListener(topics = "order.accepted")
    public void handleOrderAccepted(OrderEvent event) {
        productService.decrementStock(event.getOrder().getItems());
    }
}
```

---

### 5.3 Comunicação em Tempo Real (WebSocket)

**Uso**: Chat, notificações em tempo real

**Tecnologia**: WebSocket + STOMP + Redis PubSub

**Fluxo**:
1. Cliente conecta via WebSocket ao Chat Service
2. Cliente se inscreve no tópico `/topic/chat/{orderId}`
3. Quando mensagem é enviada, Chat Service:
   - Salva no MongoDB
   - Publica no Redis PubSub
4. Todas as instâncias do Chat Service recebem via Redis
5. Entregam via WebSocket aos clientes conectados

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws/chat")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}
```

---

## 6. Estratégias de Resiliência

### 6.1 Circuit Breaker (Resilience4j)

Protege serviços de falhas em cascata.

```java
@CircuitBreaker(name = "productService", fallbackMethod = "getProductFallback")
public Product getProduct(Long id) {
    return productServiceClient.getProduct(id);
}

public Product getProductFallback(Long id, Exception ex) {
    return Product.builder().id(id).name("Indisponível").build();
}
```

### 6.2 Retry

Retenta operações que falharam temporariamente.

```java
@Retry(name = "orderService", maxAttempts = 3)
public Order createOrder(OrderRequest request) {
    return orderServiceClient.createOrder(request);
}
```

### 6.3 Rate Limiting

Protege serviços de sobrecarga.

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: order-service
          uri: lb://order-service
          filters:
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 10
                redis-rate-limiter.burstCapacity: 20
```

### 6.4 Timeout

Define tempo máximo de espera.

```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 5000
```

---

## 7. Banco de Dados

### 7.1 Database per Service Pattern

Cada microsserviço possui seu próprio banco de dados, garantindo:
- **Isolamento**: Falha no banco de um serviço não afeta outros
- **Autonomia**: Cada serviço escolhe a tecnologia de banco mais adequada
- **Escalabilidade**: Cada banco pode ser escalado independentemente

### 7.2 Escolha de Tecnologias

| **Serviço** | **Banco de Dados** | **Justificativa** |
|-------------|-------------------|-------------------|
| Keycloak | PostgreSQL | Dados de usuários gerenciados pelo próprio Keycloak |
| Product Service | PostgreSQL + Redis | Dados relacionais + cache para performance |
| Order Service | PostgreSQL | Transações complexas, integridade referencial |
| Delivery Service | PostgreSQL | Dados relacionais |
| Chat Service | MongoDB + Redis | Documentos flexíveis, alto volume de escrita, PubSub |
| Report Service | PostgreSQL (Read Replica) | Queries analíticas, separação de carga |

### 7.3 Consistência Eventual

Para operações que envolvem múltiplos serviços, usamos **Saga Pattern**:

**Exemplo: Aceitar Pedido**
1. Order Service aceita pedido (transação local)
2. Publica evento `order.accepted`
3. Product Service decrementa estoque
   - Se falhar: Publica `stock.decrement.failed`
   - Order Service compensa: cancela pedido

---

## 8. Segurança

### 8.1 Autenticação e Autorização

**Estratégia**: OAuth 2.0 / OpenID Connect com Keycloak

**Fluxo de Autenticação**:
1. Cliente faz login via Keycloak (Authorization Code Flow)
2. Keycloak retorna Access Token (JWT, 5 min) + Refresh Token (30 min) + ID Token
3. Cliente envia Access Token em todas as requisições (`Authorization: Bearer <token>`)
4. API Gateway valida token JWT localmente (verifica assinatura com chave pública do Keycloak)
5. Se válido, extrai roles e roteia para serviço destino
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
  "service": "order-service",
  "traceId": "abc123",
  "spanId": "def456",
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

### 9.3 Distributed Tracing

- **Ferramenta**: Spring Cloud Sleuth + Zipkin
- **Propósito**: Rastrear requisições através de múltiplos serviços

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
FROM openjdk:17-slim
WORKDIR /app
COPY target/order-service.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 10.3 Kubernetes Deployment Exemplo

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: order-service:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
```

---

## 11. Escalabilidade

### 11.1 Horizontal Scaling

Todos os serviços são **stateless** e podem ser escalados horizontalmente:

```bash
kubectl scale deployment order-service --replicas=5
```

### 11.2 Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

## 12. Justificativa Técnica das Escolhas

| **Decisão** | **Justificativa** | **Alternativas Consideradas** |
|-------------|-------------------|-------------------------------|
| **Microsserviços** | Escalabilidade, manutenibilidade, alinhamento com requisitos acadêmicos | Monolito (mais simples, mas menos escalável) |
| **Keycloak** | Padrão OAuth 2.0, SSO, recursos prontos, reduz desenvolvimento | Auth-service próprio (mais complexo e inseguro) |
| **Spring Boot** | Ecossistema maduro, produtividade, integração com Spring Cloud | Quarkus, Micronaut (menos material acadêmico) |
| **Kafka** | Alto throughput, persistência, replay de eventos | RabbitMQ (mais simples, mas menos escalável) |
| **WebSocket + STOMP** | Bidirecional, baixa latência, padrão da indústria | Server-Sent Events (unidirecional) |
| **PostgreSQL** | ACID, confiabilidade, SQL completo | MySQL (similar), MongoDB (não relacional) |
| **MongoDB (chat)** | Escrita rápida, schema flexível, alta volumetria | PostgreSQL+JSONB (mais consistência) |
| **Kubernetes** | Orquestração robusta, auto-healing, scaling | Docker Swarm (mais simples, menos recursos) |
| **React** | Componentização, ecossistema rico, demanda de mercado | Vue, Angular (menos adoção) |

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
