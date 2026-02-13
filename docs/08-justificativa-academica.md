# 🎓 Justificativa Acadêmica

## 1. Introdução

Este documento apresenta o alinhamento do projeto de Backoffice de Sistema de Delivery com as disciplinas acadêmicas do período, demonstrando como cada componente do sistema aplica conceitos teóricos na prática, cumprindo os objetivos pedagógicos estabelecidos.

---

## 2. Disciplinas Contempladas

### 2.1 Visão Geral

| **Disciplina** | **Carga Horária** | **Peso no Projeto** | **Componentes Principais** |
|----------------|-------------------|---------------------|---------------------------|
| Desenvolvimento Web | 80h | 30% | Frontend React, APIs REST, Backend Spring Boot |
| Modelagem de Interfaces de Usuário | 60h | 25% | UI/UX Design, Componentes React, Responsividade |
| Design de Software | 80h | 25% | Arquitetura, Padrões de Projeto, Clean Code |
| Mensageria e Streams | 60h | 20% | Kafka, WebSocket, Redis Pub/Sub, Eventos |

---

## 3. Desenvolvimento Web

### 3.1 Conceitos Aplicados

#### 3.1.1 Frontend Moderno (React)

**Conceitos Teóricos:**
- Single Page Application (SPA)
- Componentização
- Virtual DOM
- Estado e Ciclo de Vida
- Hooks e Functional Components
- Gerenciamento de Estado (Redux/Zustand)

**Aplicação no Projeto:**

```javascript
// Exemplo: Componente de Listagem de Pedidos
const OrderList = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Carregar pedidos
    fetchOrders();
    
    // Conectar WebSocket para atualizações em tempo real
    const ws = connectWebSocket();
    ws.subscribe('/topic/orders', handleNewOrder);
    
    return () => ws.disconnect();
  }, []);
  
  const handleNewOrder = (order) => {
    setOrders(prev => [order, ...prev]);
    playNotificationSound();
  };
  
  return (
    <div>
      {loading ? <Spinner /> : orders.map(order => 
        <OrderCard key={order.id} order={order} />
      )}
    </div>
  );
};
```

**Competências Desenvolvidas:**
- Construção de interfaces reativas
- Gerenciamento de estado assíncrono
- Integração com APIs REST
- Otimização de rendering (React.memo, useMemo, useCallback)

#### 3.1.2 Backend com Spring Boot

**Conceitos Teóricos:**
- API RESTful
- Inversão de Controle (IoC)
- Injeção de Dependências
- Anotações e Reflexão
- JPA/Hibernate (ORM)
- Transações ACID

**Aplicação no Projeto:**

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    // GET: Listar pedidos com paginação
    @GetMapping
    public Page<OrderDTO> listOrders(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) OrderStatus status
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return orderService.findAll(status, pageable);
    }
    
    // POST: Aceitar pedido
    @PatchMapping("/{id}/accept")
    @Transactional
    public ResponseEntity<OrderDTO> acceptOrder(@PathVariable Long id) {
        OrderDTO order = orderService.acceptOrder(id);
        return ResponseEntity.ok(order);
    }
}
```

**Competências Desenvolvidas:**
- Design de APIs RESTful seguindo convenções HTTP
- Manipulação de dados com JPA
- Implementação de transações
- Validação e tratamento de erros

#### 3.1.3 Comunicação Cliente-Servidor

**Conceitos Aplicados:**
- Protocolo HTTP/HTTPS
- JSON como formato de troca de dados
- Status codes HTTP semânticos
- CORS (Cross-Origin Resource Sharing)
- Autenticação baseada em token (JWT)

**Evidência no Projeto:**
- APIs RESTful com verbos semânticos (GET, POST, PUT, PATCH, DELETE)
- Responses padronizados com status codes apropriados
- JWT para autenticação stateless
- WebSocket para comunicação bidirecional

### 3.2 Entregáveis para Avaliação

- [ ] **Frontend React completo**: Dashboard interativo e responsivo
- [ ] **6 Microsserviços REST**: APIs documentadas com OpenAPI/Swagger
- [ ] **Integração completa**: Frontend consumindo todas as APIs
- [ ] **Documentação de APIs**: Endpoints, payloads, exemplos
- [ ] **Testes de API**: Postman Collection ou testes automatizados

---

## 4. Modelagem de Interfaces de Usuário

### 4.1 Conceitos Aplicados

#### 4.1.1 Princípios de Design

**Conceitos Teóricos:**
- **Gestalt**: Agrupamento visual, proximidade, similaridade
- **Hierarquia Visual**: Tamanho, cor, contraste, espaçamento
- **Feedback Visual**: Estados de loading, sucesso, erro
- **Affordance**: Elementos que sugerem sua função
- **Consistência**: Padrões repetidos em toda a interface

**Aplicação no Projeto:**

**Dashboard de Pedidos:**
```
┌─────────────────────────────────────────────────────────────┐
│  🏪 Backoffice Delivery                     👤 Admin  [⚙️]  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📊 Dashboard    📦 Pedidos    🍔 Produtos    📈 Relatórios  │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📊 Métricas do Dia                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ 🛒 Pedidos   │ │ 💰 Faturamento│ │ ⏱️ Tempo Médio│       │
│  │     45       │ │   R$ 2.450   │ │   28 min     │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                              │
│  📦 Pedidos Ativos (12)                     [🔄 Tempo Real] │
│  ┌────────────────────────────────────────────────────────┐│
│  │ 🆕 #ORD-001  ⏰ 10:30  Cliente: João Silva             ││
│  │    🍔 2x Big Burger    R$ 45,90                        ││
│  │    [✅ Aceitar]  [❌ Recusar]          💬 3 mensagens  ││
│  ├────────────────────────────────────────────────────────┤│
│  │ 👨‍🍳 #ORD-002  ⏰ 10:25  Cliente: Maria Santos          ││
│  │    🍕 1x Pizza Grande  R$ 58,00                        ││
│  │    Status: Em Preparo                  💬 1 mensagem   ││
│  └────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

**Princípios Aplicados:**
- **Hierarquia**: Métricas em cards destacados, pedidos listados
- **Feedback**: Badge "Tempo Real", contador de mensagens
- **Affordance**: Botões com ações claras (Aceitar/Recusar)
- **Consistência**: Mesmos ícones e cores em toda aplicação

#### 4.1.2 Design System

**Conceito:** Biblioteca de componentes reutilizáveis com design consistente

**Implementação no Projeto:**

```
Design Tokens:
├── Colors
│   ├── Primary: #1976D2 (Azul)
│   ├── Success: #4CAF50 (Verde)
│   ├── Warning: #FF9800 (Laranja)
│   ├── Error: #F44336 (Vermelho)
│   └── Neutral: #757575 (Cinza)
│
├── Typography
│   ├── Heading 1: 32px Roboto Bold
│   ├── Heading 2: 24px Roboto Bold
│   ├── Body: 16px Roboto Regular
│   └── Caption: 12px Roboto Light
│
├── Spacing
│   ├── xs: 4px
│   ├── sm: 8px
│   ├── md: 16px
│   ├── lg: 24px
│   └── xl: 32px
│
└── Components
    ├── Button (Primary, Secondary, Outlined)
    ├── Card (Default, Elevated)
    ├── Badge (Success, Warning, Error)
    ├── Modal (Small, Medium, Large)
    └── Table (Simple, Sortable, Paginated)
```

**Benefícios:**
- Consistência visual em toda aplicação
- Desenvolvimento mais rápido (componentes reutilizáveis)
- Manutenibilidade facilitada

#### 4.1.3 Responsividade

**Conceitos Teóricos:**
- Mobile First
- Breakpoints
- Flexbox e Grid Layout
- Media Queries

**Aplicação:**

```css
/* Mobile First - Base styles para mobile */
.order-card {
  width: 100%;
  padding: 16px;
  display: flex;
  flex-direction: column;
}

/* Tablet (768px+) */
@media (min-width: 768px) {
  .order-card {
    flex-direction: row;
    align-items: center;
  }
}

/* Desktop (1024px+) */
@media (min-width: 1024px) {
  .order-list {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
}
```

#### 4.1.4 Acessibilidade (WCAG 2.1)

**Conceitos Aplicados:**
- Contraste de cores adequado (mínimo 4.5:1)
- Navegação por teclado (Tab, Enter, Esc)
- Labels e ARIA attributes
- Feedback para leitores de tela

**Exemplo:**

```jsx
<button
  onClick={handleAcceptOrder}
  aria-label="Aceitar pedido #ORD-001"
  className="btn-primary"
  disabled={loading}
>
  {loading ? <Spinner /> : 'Aceitar'}
</button>
```

### 4.2 Wireframes e Protótipos

**Ferramentas Utilizadas:**
- Figma ou Adobe XD para wireframes
- Invision ou Marvel para protótipos interativos

**Telas Principais:**
1. Login
2. Dashboard (visão geral)
3. Listagem de Pedidos
4. Detalhes do Pedido (com chat)
5. Gestão de Produtos
6. Gestão de Entregas
7. Relatórios

### 4.3 Entregáveis para Avaliação

- [ ] **Design System documentado**: Tokens, componentes, guia de uso
- [ ] **Wireframes de todas as telas**: Baixa e alta fidelidade
- [ ] **Protótipo interativo**: Simulando fluxos principais
- [ ] **Interface implementada**: Todas as telas funcionais
- [ ] **Teste de Usabilidade**: Com usuários reais, relatório de feedback
- [ ] **Relatório de Acessibilidade**: Auditoria com ferramentas (Lighthouse, axe)

---

## 5. Design de Software

### 5.1 Conceitos Aplicados

#### 5.1.1 Arquitetura de Software

**Padrão Arquitetural:** Microsserviços

**Justificativa Acadêmica:**
Demonstra conhecimento de arquiteturas modernas, escaláveis e amplamente adotadas na indústria.

**Princípios Aplicados:**

| **Princípio** | **Aplicação no Projeto** |
|---------------|--------------------------|
| **Single Responsibility** | Cada microsserviço tem uma única responsabilidade |
| **Separation of Concerns** | Camadas bem definidas (Controller, Service, Repository) |
| **Loose Coupling** | Comunicação via eventos (Kafka) |
| **High Cohesion** | Funcionalidades relacionadas agrupadas no mesmo serviço |

#### 5.1.2 Padrões de Projeto (Design Patterns)

**Padrões Utilizados:**

##### **1. Padrão MVC (Model-View-Controller)**

```
Frontend (View) ←→ Backend (Controller + Model)

View (React):        Controller (Spring):      Model (JPA):
- OrderList.jsx      - OrderController.java    - Order.java
- ProductForm.jsx    - ProductController.java  - Product.java
```

##### **2. Repository Pattern**

```java
// Abstração do acesso a dados
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByStatus(OrderStatus status);
    Page<Order> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end, Pageable pageable);
}
```

**Benefício:** Desacopla lógica de negócio do acesso a dados.

##### **3. Service Layer Pattern**

```java
// Lógica de negócio centralizada
@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private KafkaProducer kafkaProducer;
    
    @Transactional
    public Order acceptOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new NotFoundException("Order not found"));
        
        // Regra de negócio: só pode aceitar se estiver RECEIVED
        if (order.getStatus() != OrderStatus.RECEIVED) {
            throw new BusinessException("Order cannot be accepted");
        }
        
        order.setStatus(OrderStatus.ACCEPTED);
        order.setAcceptedAt(LocalDateTime.now());
        
        Order saved = orderRepository.save(order);
        
        // Publicar evento
        kafkaProducer.send("order.accepted", new OrderAcceptedEvent(saved));
        
        return saved;
    }
}
```

##### **4. Factory Pattern**

```java
// Factory para criar diferentes tipos de relatórios
public class ReportFactory {
    public static Report createReport(ReportType type) {
        return switch (type) {
            case SALES -> new SalesReport();
            case STOCK -> new StockReport();
            case DELIVERY -> new DeliveryReport();
        };
    }
}
```

##### **5. Strategy Pattern**

```java
// Diferentes estratégias de atribuição de entregadores
public interface AssignmentStrategy {
    DeliveryPerson assign(Order order, List<DeliveryPerson> available);
}

public class NearestAssignmentStrategy implements AssignmentStrategy {
    public DeliveryPerson assign(Order order, List<DeliveryPerson> available) {
        // Lógica: escolher mais próximo
    }
}

public class RoundRobinAssignmentStrategy implements AssignmentStrategy {
    public DeliveryPerson assign(Order order, List<DeliveryPerson> available) {
        // Lógica: revezamento
    }
}
```

##### **6. Observer Pattern**

Implementado via **Event-Driven Architecture** com Kafka:

```java
// Producer (Subject)
kafkaTemplate.send("order.created", orderEvent);

// Consumer (Observer)
@KafkaListener(topics = "order.created")
public void handleOrderCreated(OrderCreatedEvent event) {
    chatService.createChat(event.getOrderId());
}
```

##### **7. State Pattern**

Máquina de estados do pedido:

```java
public enum OrderStatus {
    RECEIVED {
        @Override
        public OrderStatus accept() { return ACCEPTED; }
        
        @Override
        public OrderStatus reject() { return REJECTED; }
    },
    ACCEPTED {
        @Override
        public OrderStatus startPreparation() { return IN_PREPARATION; }
    },
    IN_PREPARATION {
        @Override
        public OrderStatus markReady() { return READY; }
    },
    // ... outros estados
    
    public OrderStatus accept() { throw new IllegalStateException(); }
    public OrderStatus reject() { throw new IllegalStateException(); }
    public OrderStatus startPreparation() { throw new IllegalStateException(); }
    public OrderStatus markReady() { throw new IllegalStateException(); }
}
```

#### 5.1.3 Princípios SOLID

| **Princípio** | **Exemplo no Projeto** |
|---------------|------------------------|
| **S** - Single Responsibility | OrderService só cuida de lógica de pedidos |
| **O** - Open/Closed | AssignmentStrategy pode ser estendido sem modificar código existente |
| **L** - Liskov Substitution | Qualquer AssignmentStrategy pode ser usado indistintamente |
| **I** - Interface Segregation | Interfaces específicas (OrderRepository, ProductRepository) |
| **D** - Dependency Inversion | OrderService depende de abstrações (interfaces), não implementações |

#### 5.1.4 Clean Code

**Práticas Aplicadas:**

```java
// RUIM
public void p(int x, int y) {
    int z = x + y;
    System.out.println(z);
}

// BOM
public void processOrder(int orderId, int customerId) {
    int totalPrice = calculateTotalPrice(orderId);
    logger.info("Order processed: {}, Total: {}", orderId, totalPrice);
}
```

**Princípios:**
- Nomes significativos
- Funções pequenas (< 20 linhas)
- Sem duplicação de código (DRY - Don't Repeat Yourself)
- Comentários apenas quando necessário
- Formatação consistente

#### 5.1.5 Testes

**Pirâmide de Testes:**

```
        /\
       /  \  E2E Tests (10%)
      /____\
     /      \
    / Integr \  Integration Tests (30%)
   /__________\
  /            \
 /    Unit      \  Unit Tests (60%)
/________________\
```

**Exemplo de Teste Unitário:**

```java
@ExtendWith(MockitoExtension.class)
public class OrderServiceTest {
    
    @Mock
    private OrderRepository orderRepository;
    
    @Mock
    private KafkaProducer kafkaProducer;
    
    @InjectMocks
    private OrderService orderService;
    
    @Test
    public void shouldAcceptOrderSuccessfully() {
        // Given
        Order order = new Order();
        order.setId(1L);
        order.setStatus(OrderStatus.RECEIVED);
        
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        when(orderRepository.save(any())).thenReturn(order);
        
        // When
        Order result = orderService.acceptOrder(1L);
        
        // Then
        assertEquals(OrderStatus.ACCEPTED, result.getStatus());
        assertNotNull(result.getAcceptedAt());
        verify(kafkaProducer, times(1)).send(eq("order.accepted"), any());
    }
    
    @Test
    public void shouldThrowExceptionWhenOrderNotFound() {
        // Given
        when(orderRepository.findById(999L)).thenReturn(Optional.empty());
        
        // When & Then
        assertThrows(NotFoundException.class, () -> orderService.acceptOrder(999L));
    }
}
```

### 5.2 Entregáveis para Avaliação

- [ ] **Diagrama de Arquitetura**: Microsserviços e suas relações
- [ ] **Diagrama de Classes**: Principais entidades e relacionamentos
- [ ] **Documentação de Padrões**: Padrões utilizados e justificativas
- [ ] **Código Fonte**: Seguindo princípios SOLID e Clean Code
- [ ] **Testes Automatizados**: Cobertura > 70%
- [ ] **Análise Estática**: SonarQube ou similar (sem code smells críticos)

---

## 6. Mensageria e Streams em Aplicações

### 6.1 Conceitos Aplicados

#### 6.1.1 Event-Driven Architecture (EDA)

**Conceito:** Arquitetura baseada em eventos onde serviços se comunicam de forma assíncrona.

**Aplicação no Projeto:**

```
[Order Service] ──publish──> [order.accepted] ──subscribe──> [Product Service]
                                    │                              │
                                    │                              ▼
                                    │                     Decrement Stock
                                    │
                             ──subscribe──> [Chat Service]
                                                    │
                                                    ▼
                                           Send System Message
```

**Benefícios:**
- **Desacoplamento**: Serviços não conhecem uns aos outros diretamente
- **Escalabilidade**: Adicionar novos consumidores sem modificar produtores
- **Resiliência**: Falha em um serviço não afeta outros
- **Auditoria**: Histórico completo de eventos

#### 6.1.2 Apache Kafka

**Conceitos Teóricos:**
- **Tópicos**: Categorias de mensagens
- **Partições**: Divisão de um tópico para paralelização
- **Producers**: Publicam mensagens
- **Consumers**: Consomem mensagens
- **Consumer Groups**: Múltiplos consumidores trabalhando em paralelo
- **Offset**: Posição de leitura no log
- **Retention**: Tempo de retenção de mensagens

**Implementação no Projeto:**

**Producer:**

```java
@Service
public class OrderEventProducer {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void publishOrderAccepted(Order order) {
        OrderAcceptedEvent event = OrderAcceptedEvent.builder()
                .orderId(order.getId())
                .orderNumber(order.getOrderNumber())
                .items(order.getItems())
                .timestamp(LocalDateTime.now())
                .build();
        
        // Key: orderId garante que eventos do mesmo pedido vão para mesma partição
        kafkaTemplate.send("order.accepted", order.getId().toString(), event);
    }
}
```

**Consumer:**

```java
@Service
public class ProductEventConsumer {
    
    @Autowired
    private ProductService productService;
    
    @KafkaListener(
        topics = "order.accepted",
        groupId = "product-service",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleOrderAccepted(OrderAcceptedEvent event) {
        logger.info("Received order.accepted event: {}", event.getOrderId());
        
        event.getItems().forEach(item -> {
            productService.decrementStock(item.getProductId(), item.getQuantity());
        });
        
        logger.info("Stock updated for order: {}", event.getOrderId());
    }
}
```

**Configuração:**

```java
@Configuration
public class KafkaConfig {
    
    @Bean
    public ProducerFactory<String, OrderEvent> producerFactory() {
        Map<String, Object> config = new HashMap<>();
        config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        config.put(ProducerConfig.ACKS_CONFIG, "all"); // Garantia de entrega
        config.put(ProducerConfig.RETRIES_CONFIG, 3); // Retry automático
        return new DefaultKafkaProducerFactory<>(config);
    }
    
    @Bean
    public ConsumerFactory<String, OrderEvent> consumerFactory() {
        Map<String, Object> config = new HashMap<>();
        config.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        config.put(ConsumerConfig.GROUP_ID_CONFIG, "product-service");
        config.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        config.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
        config.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // Ler desde o início
        config.put(JsonDeserializer.TRUSTED_PACKAGES, "*");
        return new DefaultKafkaConsumerFactory<>(config);
    }
}
```

#### 6.1.3 WebSocket + STOMP

**Conceito:** Protocolo de comunicação bidirecional full-duplex para tempo real.

**Comparação:**

| **Tecnologia** | **Comunicação** | **Latência** | **Uso no Projeto** |
|----------------|-----------------|--------------|-------------------|
| HTTP/REST      | Request/Response | ~100ms | APIs CRUD |
| WebSocket      | Full-Duplex | ~10ms | Chat, Notificações |
| Kafka          | Pub/Sub Assíncrono | ~50ms | Eventos entre serviços |

**Implementação:**

```java
// Backend - Message Handler
@MessageMapping("/chat.send")
public void sendMessage(@Payload ChatMessageDTO message) {
    // Save to MongoDB
    ChatMessage saved = chatService.save(message);
    
    // Publish to Redis (para sincronizar entre instâncias)
    redisPublisher.publish("chat." + message.getOrderId(), saved);
}

// Redis Subscriber
@Override
public void onMessage(Message message, byte[] pattern) {
    ChatMessage chatMsg = deserialize(message.getBody());
    
    // Broadcast via WebSocket
    simpMessagingTemplate.convertAndSend(
        "/topic/chat/" + chatMsg.getOrderId(),
        chatMsg
    );
}
```

```javascript
// Frontend - WebSocket Client
const stompClient = new Client({
  brokerURL: 'ws://localhost:8080/ws/chat',
  onConnect: () => {
    // Subscribe to chat topic
    stompClient.subscribe(`/topic/chat/${orderId}`, (message) => {
      const chatMessage = JSON.parse(message.body);
      addMessageToChat(chatMessage);
    });
  }
});

// Send message
const sendMessage = (content) => {
  stompClient.publish({
    destination: '/app/chat.send',
    body: JSON.stringify({
      orderId: orderId,
      content: content
    })
  });
};
```

#### 6.1.4 Redis Pub/Sub

**Conceito:** Padrão de mensageria para comunicação leve e rápida entre processos.

**Uso no Projeto:** Sincronizar mensagens do chat entre múltiplas instâncias do Chat Service.

**Por que Redis e não Kafka para chat?**
- **Latência ultra-baixa**: ~1ms vs ~50ms do Kafka
- **Simplicidade**: Ideal para mensagens efêmeras (não precisa de persistência)
- **Performance**: Otimizado para alto throughput de mensagens pequenas

#### 6.1.5 Garantias de Entrega

**At-Least-Once Delivery:**

```java
// Kafka Producer com retries e acks
config.put(ProducerConfig.ACKS_CONFIG, "all"); // Leader + replicas
config.put(ProducerConfig.RETRIES_CONFIG, 3); // Retry 3x
config.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true); // Evita duplicatas
```

**Idempotência:**

```java
// Garantir que processar o mesmo evento 2x não cause problemas
@KafkaListener(topics = "order.accepted")
public void handleOrderAccepted(OrderAcceptedEvent event) {
    // Verificar se já foi processado
    if (processedOrders.contains(event.getOrderId())) {
        logger.warn("Event already processed: {}", event.getOrderId());
        return;
    }
    
    // Processar
    productService.decrementStock(event.getItems());
    
    // Marcar como processado
    processedOrders.add(event.getOrderId());
}
```

#### 6.1.6 Saga Pattern

**Conceito:** Transações distribuídas através de eventos.

**Exemplo: Aceitar Pedido**

```
Order Service         Product Service       Chat Service
     │                      │                     │
     ├─ Accept Order        │                     │
     ├─ Save to DB          │                     │
     ├─ Publish             │                     │
     │  order.accepted ────►│                     │
     │                      ├─ Decrement Stock    │
     │                      ├─ If Success:        │
     │                      │  Publish             │
     │                      │  stock.updated ─────►│
     │                      │                     ├─ Send Msg
     │                      │                     │
     │                      ├─ If Fail:
     │                      │  Publish
     │                      │  stock.failed
     │◄─────────────────────┤
     ├─ Compensate:
     ├─ Cancel Order
```

### 6.2 Métricas e Monitoramento

**Métricas Importantes:**

```java
@Component
public class KafkaMetrics {
    
    private final MeterRegistry meterRegistry;
    
    public void recordMessageSent(String topic) {
        meterRegistry.counter("kafka.messages.sent", "topic", topic).increment();
    }
    
    public void recordMessageReceived(String topic, long lag) {
        meterRegistry.counter("kafka.messages.received", "topic", topic).increment();
        meterRegistry.gauge("kafka.consumer.lag", lag);
    }
}
```

**Dashboards:**
- Taxa de mensagens publicadas/consumidas
- Lag dos consumers
- Tempo de processamento de eventos
- Taxa de erro

### 6.3 Entregáveis para Avaliação

- [ ] **Diagrama de Eventos**: Fluxo completo de eventos no sistema
- [ ] **Configuração Kafka**: Topics, partições, replication factor
- [ ] **Implementação de Producers e Consumers**: Código funcional
- [ ] **Chat em Tempo Real**: WebSocket + STOMP funcionando
- [ ] **Sincronização Multi-instância**: Redis Pub/Sub implementado
- [ ] **Testes de Mensageria**: Testes com Kafka Embedded ou Testcontainers
- [ ] **Documentação de Eventos**: Schema registry ou documentação JSON
- [ ] **Métricas**: Dashboard Grafana com métricas de Kafka

---

## 7. Matriz de Rastreabilidade Completa

| **Requisito** | **Componente** | **Disciplina** | **Conceito Aplicado** |
|---------------|----------------|----------------|----------------------|
| RF001-RF005 (Auth) | Auth Service, JWT Filter | Desenvolvimento Web | REST API, Spring Security |
| RF010-RF019 (Produtos) | Product Service, ProductCRUD | Desenvolvimento Web | CRUD REST, JPA |
| RF020-RF029 (Pedidos) | Order Service, State Machine | Design de Software | State Pattern, SOLID |
| RF030-RF036 (Entregas) | Delivery Service | Desenvolvimento Web | REST API, Relacionamentos |
| RF040-RF048 (Chat) | Chat Service, WebSocket | Mensageria e Streams | WebSocket, STOMP, Redis |
| RF050-RF059 (Relatórios) | Report Service | Desenvolvimento Web | Queries complexas, Aggregation |
| RNF001-RNF005 (Performance) | Cache, Índices | Design de Software | Otimização, Redis Cache |
| RNF010-RNF012 (Escalabilidade) | Kubernetes, Load Balancer | Design de Software | Arquitetura Microsserviços |
| RNF030-RNF036 (Segurança) | JWT, HTTPS, Validation | Desenvolvimento Web | Segurança de Aplicações |
| Interface Completa | React Frontend | Modelagem de UI | Componentes, Design System |
| Eventos Assíncronos | Kafka | Mensageria e Streams | Event-Driven Architecture |

---

## 8. Diferenciais Acadêmicos do Projeto

### 8.1 Complexidade Técnica

- **Arquitetura Distribuída**: 6+ microsserviços independentes
- **Múltiplas Tecnologias**: Java, JavaScript, PostgreSQL, MongoDB, Redis, Kafka
- **Comunicação Híbrida**: Síncrona (REST), Assíncrona (Kafka), Tempo Real (WebSocket)

### 8.2 Aplicação Prática

- Simula ambiente real de produção
- Tecnologias amplamente usadas na indústria
- Problemas reais (consistência, escalabilidade, latência)

### 8.3 Conceitos Avançados

- Event Sourcing
- CQRS (Command Query Responsibility Segregation)
- Circuit Breaker
- API Gateway Pattern
- Saga Pattern

### 8.4 DevOps e Cloud Native

- Containerização (Docker)
- Orquestração (Kubernetes)
- CI/CD Pipeline
- Monitoramento (Prometheus, Grafana)
- Logs Centralizados (ELK Stack)

---

## 9. Critérios de Avaliação Sugeridos

### 9.1 Desenvolvimento Web (30 pontos)

- [ ] Frontend React funcional (10pts)
- [ ] APIs REST completas (10pts)
- [ ] Integração frontend-backend (5pts)
- [ ] Documentação de APIs (5pts)

### 9.2 Modelagem de UI (25 pontos)

- [ ] Design System (5pts)
- [ ] Wireframes e protótipos (5pts)
- [ ] Interface implementada (10pts)
- [ ] Teste de usabilidade (5pts)

### 9.3 Design de Software (25 pontos)

- [ ] Arquitetura documentada (5pts)
- [ ] Padrões de projeto aplicados (10pts)
- [ ] Código limpo e SOLID (5pts)
- [ ] Testes automatizados (5pts)

### 9.4 Mensageria e Streams (20 pontos)

- [ ] Kafka implementado (5pts)
- [ ] WebSocket + STOMP funcionando (10pts)
- [ ] Redis Pub/Sub (3pts)
- [ ] Documentação de eventos (2pts)

---

## 10. Conclusão

Este projeto integra de forma coesa e balanceada as quatro disciplinas do período letivo, aplicando conceitos teóricos em um contexto prático e relevante. A escolha de tecnologias modernas e amplamente adotadas no mercado prepara os alunos para desafios reais da engenharia de software, ao mesmo tempo que satisfaz os objetivos pedagógicos de cada disciplina.

**Aprendizados Esperados:**

- Domínio de desenvolvimento full-stack moderno
- Experiência com arquitetura de microsserviços
- Conhecimento de comunicação assíncrona e tempo real
- Habilidades de design de interfaces centradas no usuário
- Capacidade de aplicar padrões de projeto e boas práticas
- Experiência com DevOps e infraestrutura cloud-native

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
