# 📊 Diagramas do Sistema

## 1. Introdução

Este documento apresenta os principais diagramas UML e arquiteturais do sistema, facilitando a compreensão da estrutura, comportamento e implantação.

---

## 2. Diagrama de Componentes

### 2.1 Visão Geral dos Componentes

```
┌────────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    React Application                             │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │  │
│  │  │   Product    │  │    Order     │  │   Delivery   │         │  │
│  │  │   Module     │  │   Module     │  │   Module     │         │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │  │
│  │  │     Chat     │  │    Report    │  │     Auth     │         │  │
│  │  │   Module     │  │   Module     │  │   Module     │         │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │  │
│  │                                                                  │  │
│  │  ┌────────────────────────────────────────────────────────┐   │  │
│  │  │          Shared Components & Services                   │   │  │
│  │  │  - HTTP Client  - WebSocket Client  - State Management │   │  │
│  │  └────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────┬────────────────────────────────────────┘
                                │ HTTPS / WSS
                                │
┌───────────────────────────────▼────────────────────────────────────────┐
│                        API GATEWAY                                      │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │  Spring Cloud Gateway                                             │ │
│  │  - JWT Authentication Filter                                      │ │
│  │  - Rate Limiting Filter                                           │ │
│  │  - Logging Filter                                                 │ │
│  │  - Dynamic Routing (Eureka Integration)                           │ │
│  └──────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────┬────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
┌───────▼──────┐       ┌────────▼────────┐     ┌──────▼─────────┐
│   Eureka     │       │  Config Server  │     │     Kafka      │
│   Server     │       │   (Git Backend) │     │    Cluster     │
│              │       │                 │     │   - Broker 1   │
│  - Service   │       │  - Central      │     │   - Broker 2   │
│    Registry  │       │    Config       │     │   - Zookeeper  │
│  - Health    │       │  - Refresh      │     │                │
│    Check     │       │    Endpoint     │     │  Topics:       │
└──────────────┘       └─────────────────┘     │   order.*      │
                                                │   delivery.*   │
                                                │   chat.*       │
                                                └────────┬───────┘
                                                         │
┌────────────────────────────────────────────────────────▼───────────────┐
│                         MICROSERVICES                                   │
│                                                                         │
│┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐       │
││ Product Service │  │  Order Service  │  │ Delivery Service│       │
│├─────────────────┤  ├─────────────────┤  ├─────────────────┤       │
│  │ Controllers:    │  │ Controllers:    │  │ Controllers:    │       │
│  │ - ProductCtrler │  │ - OrderCtrler   │  │ - DeliveryCtrler│       │
│  │ - CategoryCtrler│  │                 │  │                 │       │
│  │                 │  │                 │  │                 │       │
│  │ Services:       │  │ Services:       │  │ Services:       │       │
│  │ - ProductSvc    │  │ - OrderService  │  │ - DeliverySvc   │       │
│  │ - StockSvc      │  │ - OrderEvent    │  │                 │       │
│  │ - CacheSvc      │  │   Producer      │  │                 │       │
│  │                 │  │                 │  │                 │       │
│  │ Repositories:   │  │ Repositories:   │  │ Repositories:   │       │
│  │ - ProductRepo   │  │ - OrderRepo     │  │ - DeliveryRepo  │       │
│  │ - CategoryRepo  │  │ - CustomerRepo  │  │                 │       │
│  │                 │  │                 │  │                 │       │
│  │ Event Consumer: │  │ Event Producer: │  │                 │       │
│  │ - OrderAccepted │  │ - OrderCreated  │  │                 │       │
│  │   Handler       │  │ - OrderAccepted │  │                 │       │
│  │                 │  │ - StatusChanged │  │                 │       │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘       │
│           │                    │                     │                │
│      ┌────▼─────┐        ┌────▼─────┐         ┌────▼─────┐          │
│      │PostgreSQL│        │PostgreSQL│         │PostgreSQL│          │
│      │product_db│        │ order_db │         │delivery_db│          │
│      │   +      │        └──────────┘         └──────────┘          │
│      │  Redis   │                                                    │
│      │ (Cache)  │                                                    │
│      └──────────┘                                                    │
│                          │  Redis   │                                │
│                          │ (Cache)  │                                │
│                          └──────────┘                                │
│                                                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │ Delivery Service│  │  Chat Service   │  │ Report Service  │     │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤     │
│  │ Controllers:    │  │ Controllers:    │  │ Controllers:    │     │
│  │ - DeliveryCtrlr │  │ - ChatCtrler    │  │ - ReportCtrler  │     │
│  │ - PersonCtrler  │  │                 │  │                 │     │
│  │                 │  │ WebSocket:      │  │ Services:       │     │
│  │ Services:       │  │ - MessageHdlr   │  │ - SalesReport   │     │
│  │ - DeliverySvc   │  │ - ChatHandler   │  │ - StockReport   │     │
│  │ - Assignment    │  │                 │  │ - Metrics       │     │
│  │   Service       │  │ Services:       │  │                 │     │
│  │                 │  │ - ChatService   │  │ Repositories:   │     │
│  │ Repositories:   │  │ - MessageSvc    │  │ - OrderRepo     │     │
│  │ - DeliveryRepo  │  │ - RedisPubSub   │  │   (Read Only)   │     │
│  │ - PersonRepo    │  │                 │  │ - ProductRepo   │     │
│  │                 │  │ Repositories:   │  │   (Read Only)   │     │
│  │ Event Consumer: │  │ - ChatRepo      │  │                 │     │
│  │ - OrderReady    │  │ - MessageRepo   │  │ Event Consumer: │     │
│  │   Handler       │  │   (MongoDB)     │  │ - All Events    │     │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘     │
│           │                    │                     │              │
│      ┌────▼─────┐        ┌────▼─────┐         ┌────▼─────┐        │
│      │PostgreSQL│        │ MongoDB  │         │PostgreSQL│        │
│      │delivery  │        │   +      │         │ order_db │        │
│      │   _db    │        │  Redis   │         │ (Replica)│        │
│      └──────────┘        │ (PubSub) │         └──────────┘        │
│                          └──────────┘                              │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        INFRASTRUCTURE                                    │
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │ Prometheus   │  │   Grafana    │  │  ELK Stack   │                 │
│  │ (Metrics)    │  │ (Dashboards) │  │   (Logs)     │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Diagrama de Sequência - Fluxo de Pedido

### 3.1 Fluxo Completo: Receber e Processar Pedido

```
┌──────┐  ┌──────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────┐
│Client│  │Gateway│ │  Order  │  │ Product │  │  Chat   │  │Kafka │
│ App  │  │       │  │ Service │  │ Service │  │ Service │  │      │
└───┬──┘  └───┬───┘  └────┬────┘  └────┬────┘  └────┬────┘  └───┬──┘
    │         │           │            │            │           │
    │ 1. POST /orders     │            │            │           │
    ├────────►│           │            │            │           │
    │         │ 2. Validate JWT        │            │           │
    │         ├──────────►│            │            │           │
    │         │           │            │            │           │
    │         │ 3. Create Order        │            │           │
    │         ├──────────►│            │            │           │
    │         │           │            │            │           │
    │         │           │ 4. Save to DB           │           │
    │         │           ├────────────┼────────────┤           │
    │         │           │            │            │           │
    │         │           │ 5. Publish event        │           │
    │         │           │ order.created           │           │
    │         │           ├────────────┼────────────┼──────────►│
    │         │           │            │            │           │
    │         │           │            │            │ 6. Create Chat
    │         │           │            │            │◄──────────┤
    │         │           │            │            │           │
    │         │ 7. Order Created       │            │           │
    │         │◄──────────┤            │            │           │
    │         │           │            │            │           │
    │ 8. 201 Created      │            │            │           │
    │◄────────┤           │            │            │           │
    │         │           │            │            │           │
    │ 9. WS: Order Notification         │           │           │
    │◄────────┴───────────┴────────────┴────────────┤           │
    │         │           │            │            │           │
    │ 10. PATCH /orders/123/accept     │            │           │
    ├────────►│           │            │            │           │
    │         │ 11. Validate & Route   │            │           │
    │         ├──────────►│            │            │           │
    │         │           │            │            │           │
    │         │           │ 12. Update Status       │           │
    │         │           ├────────────┤            │           │
    │         │           │            │            │           │
    │         │           │ 13. Publish event       │           │
    │         │           │ order.accepted          │           │
    │         │           ├────────────┼────────────┼──────────►│
    │         │           │            │            │           │
    │         │           │            │ 14. Consume Event      │
    │         │           │            │◄───────────┼───────────┤
    │         │           │            │            │           │
    │         │           │            │ 15. Decrement Stock    │
    │         │           │            ├────────────┤           │
    │         │           │            │            │           │
    │         │           │            │            │ 16. Consume Event
    │         │           │            │            │◄──────────┤
    │         │           │            │            │           │
    │         │           │            │            │ 17. Send Msg
    │         │           │            │            │"Pedido aceito!"
    │         │           │            │            ├────────────┤
    │         │           │            │            │           │
    │ 18. WS: Chat Message │           │            │           │
    │◄────────┴───────────┴────────────┴────────────┤           │
    │         │           │            │            │           │
```

### 3.2 Descrição do Fluxo

1. **Cliente cria pedido** via POST /orders através do Gateway
2. **Gateway valida JWT** com Keycloak (verificação de assinatura local)
3. **Order Service** cria o pedido e salva no banco
4. **Order Service** publica evento `order.created` no Kafka
5. **Chat Service** consome o evento e cria automaticamente o chat
6. **Cliente recebe confirmação** com ID do pedido
7. **Cliente recebe notificação WebSocket** de novo pedido
8. **Operador aceita pedido** via PATCH /orders/{id}/accept
9. **Order Service** atualiza status e publica evento `order.accepted`
10. **Product Service** consome evento e decrementa estoque
11. **Chat Service** consome evento e envia mensagem automática no chat
12. **Cliente e operador recebem mensagem via WebSocket**

---

## 4. Diagrama de Sequência - Chat em Tempo Real

```
┌───────┐  ┌────────┐  ┌──────────┐  ┌────────┐  ┌─────────┐
│Store  │  │ Chat   │  │  Redis   │  │  Chat  │  │Customer │
│Client │  │Service │  │  PubSub  │  │Service │  │ Client  │
└───┬───┘  └───┬────┘  └────┬─────┘  └───┬────┘  └────┬────┘
    │          │            │            │            │
    │ 1. Connect WS         │            │            │
    ├─────────►│            │            │            │
    │          │            │            │            │
    │ 2. Subscribe to topic │            │            │
    │    /topic/chat/123    │            │            │
    ├─────────►│            │            │            │
    │          │            │            │            │
    │          │            │            │ 3. Connect WS
    │          │            │            │◄───────────┤
    │          │            │            │            │
    │          │            │            │ 4. Subscribe
    │          │            │            │◄───────────┤
    │          │            │            │            │
    │ 5. Send Message       │            │            │
    │    "Pedido pronto"    │            │            │
    ├─────────►│            │            │            │
    │          │            │            │            │
    │          │ 6. Save to MongoDB      │            │
    │          ├────────────┤            │            │
    │          │            │            │            │
    │          │ 7. Publish to Redis     │            │
    │          ├───────────►│            │            │
    │          │            │            │            │
    │          │            │ 8. Broadcast Message    │
    │          │            ├───────────►│            │
    │          │            │            │            │
    │          │            │            │ 9. Send via WS
    │          │            │            ├───────────►│
    │          │            │            │            │
    │ 10. Confirm delivery  │            │            │
    │◄─────────┤            │            │            │
    │          │            │            │            │
    │          │            │            │ 11. Read Receipt
    │          │            │            │◄───────────┤
    │          │            │            │            │
    │          │            │            │ 12. Update DB
    │          │            │            ├────────────┤
    │          │            │            │            │
```

---

## 5. Diagrama de Implantação (Kubernetes)

```
┌─────────────────────────────────────────────────────────────────────┐
│                       KUBERNETES CLUSTER                             │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                     Ingress Controller                          │ │
│  │                  (NGINX / Traefik)                              │ │
│  │             - SSL Termination                                   │ │
│  │             - Load Balancing                                    │ │
│  └──────────────────────┬─────────────────────────────────────────┘ │
│                         │                                            │
│  ┌──────────────────────▼─────────────────────────────────────────┐ │
│  │                    API Gateway Pod                              │ │
│  │                 (Spring Cloud Gateway)                          │ │
│  │                    Replicas: 2                                  │ │
│  └──────────────────────┬─────────────────────────────────────────┘ │
│                         │                                            │
│         ┌───────────────┼───────────────┐                           │
│         │               │               │                           │
│  ┌──────▼──────┐ ┌─────▼──────┐ ┌─────▼──────┐                    │
│  │   Eureka    │ │   Config   │ │   Kafka    │                    │
│  │   Service   │ │   Service  │ │   Pod      │                    │
│  │  Replicas:2 │ │ Replicas:1 │ │ Replicas:3 │                    │
│  └─────────────┘ └────────────┘ └─────┬──────┘                    │
│                                        │                             │
│  ┌────────────────────────────────────┼──────────────────────────┐ │
│  │              NAMESPACE: microservices        │                 │ │
│  │                                              │                 │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │                 │ │
│  │  │  Auth    │  │ Product  │  │  Order   │  │                 │ │
│  │  │  Pod     │  │   Pod    │  │   Pod    │  │                 │ │
│  │  │Replicas:2│  │Replicas:3│  │Replicas:3│  │                 │ │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │                 │ │
│  │       │             │             │         │                 │ │
│  │  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐  │                 │ │
│  │  │PostgreSQL│  │PostgreSQL│  │PostgreSQL│  │                 │ │
│  │  │StatefulSet│ │StatefulSet│ │StatefulSet│ │                 │ │
│  │  │    +     │  │    +     │  │          │  │                 │ │
│  │  │   PVC    │  │  Redis   │  │   PVC    │  │                 │ │
│  │  └──────────┘  │   Pod    │  └──────────┘  │                 │ │
│  │                └──────────┘                 │                 │ │
│  │                                              │                 │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │                 │ │
│  │  │ Delivery │  │   Chat   │  │  Report  │  │                 │ │
│  │  │   Pod    │  │   Pod    │  │   Pod    │  │                 │ │
│  │  │Replicas:2│  │Replicas:3│  │Replicas:2│  │                 │ │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │                 │ │
│  │       │             │             │         │                 │ │
│  │  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐  │                 │ │
│  │  │PostgreSQL│  │ MongoDB  │  │PostgreSQL│  │                 │ │
│  │  │StatefulSet│ │StatefulSet│ │ (Replica)│  │                 │ │
│  │  │   PVC    │  │   +      │  │   PVC    │  │                 │ │
│  │  └──────────┘  │  Redis   │  └──────────┘  │                 │ │
│  │                │   Pod    │                 │                 │ │
│  │                └──────────┘                 │                 │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │            NAMESPACE: monitoring                                │ │
│  │                                                                 │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                    │ │
│  │  │Prometheus│  │ Grafana  │  │    ELK   │                    │ │
│  │  │  Pod     │  │   Pod    │  │  Stack   │                    │ │
│  │  └──────────┘  └──────────┘  └──────────┘                    │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ConfigMaps: app-configs, env-configs                                │
│  Secrets: db-credentials, jwt-secrets, api-keys                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.1 Recursos Kubernetes

**Deployments:**
- keycloak: 1 replica (2 em produção)
- product-service: 3 replicas
- order-service: 3 replicas
- delivery-service: 2 replicas
- chat-service: 3 replicas
- report-service: 2 replicas

**StatefulSets:**
- PostgreSQL databases (1 por serviço)
- MongoDB
- Redis
- Kafka

**Services:**
- ClusterIP para comunicação interna
- LoadBalancer para Ingress

**Persistent Volumes:**
- 10GB por banco PostgreSQL
- 20GB para MongoDB
- 50GB para Kafka

**HPA (Horizontal Pod Autoscaler):**
- Escala automática baseada em CPU (70%)

---

## 6. Diagrama de Caso de Uso

```
                    ┌─────────────────────────┐
                    │  Backoffice System      │
                    │                         │
    ┌───────────────┼─────────────────────────┼───────────────┐
    │               │                         │               │
    │     ┌─────────┴──────────┐    ┌────────▼────────┐     │
    │     │                    │    │                 │     │
    │     │   Gerenciar        │    │   Gerenciar     │     │
    │     │   Produtos         │    │   Pedidos       │     │
    │     │                    │    │                 │     │
    │     └────────────────────┘    └─────────────────┘     │
    │               │                         │               │
┌───▼────┐          │                         │          ┌────▼─────┐
│Operator│          │                         │          │  Admin   │
└───┬────┘   ┌──────▼──────────┐    ┌────────▼────────┐ └────┬─────┘
    │        │                 │    │                 │      │
    │        │   Comunicar     │    │   Atribuir      │      │
    │        │   via Chat      │    │   Entregas      │      │
    │        │                 │    │                 │      │
    │        └─────────────────┘    └─────────────────┘      │
    │                  │                      │               │
    └──────────────────┼──────────────────────┼───────────────┘
                       │                      │
                       │            ┌─────────▼────────┐
              ┌────────▼────────┐   │                  │
              │                 │   │   Visualizar     │
              │   Visualizar    │   │   Relatórios     │
              │   Estoque       │   │                  │
              │                 │   └──────────────────┘
              └─────────────────┘
```

---

## 7. Diagrama de Classes - Domain Model (Order Service)

```
┌────────────────────────┐
│      Customer          │
├────────────────────────┤
│ - id: Long             │
│ - name: String         │
│ - phone: String        │
│ - email: String        │
├────────────────────────┤
│ + getOrders()          │
└───────┬────────────────┘
        │ 1
        │ has
        │ *
┌───────▼────────────────┐          ┌────────────────────────┐
│       Order            │          │      Address           │
├────────────────────────┤          ├────────────────────────┤
│ - id: Long             │◄─────────│ - id: Long             │
│ - orderNumber: String  │ delivers │ - street: String       │
│ - status: OrderStatus  │   to     │ - number: String       │
│ - totalAmount: BigDec  │          │ - city: String         │
│ - createdAt: DateTime  │          │ - zipCode: String      │
├────────────────────────┤          └────────────────────────┘
│ + accept()             │
│ + reject(reason)       │
│ + updateStatus(status) │
│ + isEditable()         │
└───────┬────────────────┘
        │ 1
        │ contains
        │ *
┌───────▼────────────────┐
│      OrderItem         │
├────────────────────────┤
│ - id: Long             │
│ - productId: Long      │
│ - productName: String  │
│ - quantity: Integer    │
│ - unitPrice: BigDecimal│
│ - subtotal: BigDecimal │
├────────────────────────┤
│ + calculateSubtotal()  │
└────────────────────────┘

┌────────────────────────┐
│    <<enumeration>>     │
│      OrderStatus       │
├────────────────────────┤
│ RECEIVED               │
│ ACCEPTED               │
│ IN_PREPARATION         │
│ READY                  │
│ OUT_FOR_DELIVERY       │
│ DELIVERED              │
│ CANCELED               │
│ REJECTED               │
└────────────────────────┘
```

---

## 8. Diagrama de Estados - Pedido

```
                    [Pedido Criado]
                          │
                          ▼
                   ┌──────────────┐
                   │   RECEIVED   │
                   └──────┬───────┘
                          │
              ┌───────────┴───────────┐
              │                       │
        [Aceitar]                [Recusar]
              │                       │
              ▼                       ▼
       ┌─────────────┐         ┌─────────────┐
       │  ACCEPTED   │         │  REJECTED   │ [Final]
       └──────┬──────┘         └─────────────┘
              │
              │ [Iniciar Preparo]
              ▼
       ┌─────────────────┐
       │ IN_PREPARATION  │
       └──────┬──────────┘
              │
              │ [Finalizar Preparo]
              ▼
       ┌─────────────┐
       │    READY    │
       └──────┬──────┘
              │
              │ [Atribuir Entregador]
              ▼
       ┌──────────────────┐
       │ OUT_FOR_DELIVERY │
       └──────┬───────────┘
              │
              │ [Confirmar Entrega]
              ▼
       ┌─────────────┐
       │  DELIVERED  │ [Final]
       └─────────────┘

       * De qualquer estado (exceto finais):
         [Cancelar] → CANCELED [Final]
```

---

## 9. Diagrama C4 - Nível Container

```
                          ┌─────────────────┐
                          │   Backoffice    │
                          │      User       │
                          └────────┬────────┘
                                   │ HTTPS
                                   │
                          ┌────────▼────────┐
                          │  React Single   │
                          │  Page App       │
                          │  [JavaScript]   │
                          └────────┬────────┘
                                   │ JSON/HTTPS
                                   │ WebSocket
                          ┌────────▼────────────┐
                          │   API Gateway       │
                          │ [Spring Cloud]      │
                          └────────┬────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
┌───────▼──────┐         ┌─────────▼────────┐      ┌────────▼─────────┐
│  Keycloak    │         │ Order Service    │      │Product Service   │
│   Server     │◄────────│  [Spring Boot]   │─────►│  [Spring Boot]   │
│  [OAuth2.0]  │  Auth   └─────────┬────────┘Event └────────┬─────────┘
└───────┬──────┘                    │                        │
   ┌────▼────┐               ┌──────▼──────┐          ┌────▼────┐
   │PostgreSQL│               │  PostgreSQL │          │PostgreSQL│
   │   DB    │               │     DB      │          │ + Redis │
   └─────────┘               └──────┬──────┘          └─────────┘
                                    │
                          ┌─────────▼────────┐
                          │  Apache Kafka    │
                          │ Message Broker   │
                          └─────────┬────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌───────▼─────┐            ┌────────▼────────┐        ┌────────▼────────┐
│Chat Service │            │Delivery Service │        │ Report Service  │
│[Spring Boot]│            │  [Spring Boot]  │        │  [Spring Boot]  │
└───────┬─────┘            └────────┬────────┘        └────────┬────────┘
        │                           │                          │
 ┌──────▼──────┐            ┌───────▼──────┐          ┌───────▼──────┐
 │  MongoDB    │            │  PostgreSQL  │          │  PostgreSQL  │
 │  + Redis    │            │      DB      │          │(Read Replica)│
 └─────────────┘            └──────────────┘          └──────────────┘
```

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
