# 💬 Chat em Tempo Real - Estratégia de Implementação

## 1. Introdução

Este documento detalha a estratégia técnica para implementação do sistema de chat em tempo real integrado aos pedidos, demonstrando conceitos avançados de mensageria e streams aplicados ao contexto acadêmico.

---

## 2. Requisitos do Chat

### 2.1 Requisitos Funcionais Específicos

- **Chat por Pedido**: Cada pedido possui seu próprio canal de chat isolado
- **Participantes Dinâmicos**:
  - Loja e Cliente: Desde a criação do pedido
  - Entregador: Adicionado quando pedido sai para entrega
- **Mensagens em Tempo Real**: Latência < 100ms
- **Histórico Persistente**: Todas as mensagens armazenadas no MongoDB
- **Mensagens do Sistema**: Automáticas ao mudar status do pedido
- **Notificações Visuais**: Indicador de novas mensagens
- **Escalabilidade**: Suporte a múltiplas instâncias do serviço

### 2.2 Desafios Técnicos

1. **Multi-instância**: Como sincronizar mensagens entre múltiplas instâncias do Chat Service?
2. **Persistência + Tempo Real**: Como garantir que mensagens sejam salvas E entregues instantaneamente?
3. **Conexões WebSocket**: Como gerenciar milhares de conexões ativas?
4. **Garantia de Entrega**: Como garantir que mensagens não se percam?

---

## 3. Arquitetura da Solução

### 3.1 Stack Tecnológica

| **Componente** | **Tecnologia** | **Justificativa** |
|----------------|----------------|-------------------|
| Protocolo | WebSocket + STOMP | Bidirecional, baixa latência, padrão da indústria |
| Backend | Spring Boot + WebSocket | Integração nativa, fácil configuração |
| Message Broker | Redis Pub/Sub | Latência ultrabaixa, sincronização entre instâncias |
| Persistência | MongoDB | Schema flexível, alta volumetria de escrita |
| Cliente | SockJS + StompJS | Fallback automático, compatibilidade |

### 3.2 Arquitetura Detalhada

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
│                                                                      │
│  ┌──────────────────┐              ┌──────────────────┐            │
│  │  Store Client    │              │ Customer Client  │            │
│  │   (React App)    │              │   (Mobile App)   │            │
│  │                  │              │                  │            │
│  │ - SockJS Client  │              │ - SockJS Client  │            │
│  │ - STOMP Client   │              │ - STOMP Client   │            │
│  │ - Chat Component │              │ - Chat Component │            │
│  └────────┬─────────┘              └────────┬─────────┘            │
└───────────┼──────────────────────────────────┼─────────────────────┘
            │ WS/WSS                           │
            │ /ws/chat                         │
            │                                  │
┌───────────▼──────────────────────────────────▼─────────────────────┐
│                      LOAD BALANCER                                  │
│                 (Sticky Session Enabled)                            │
└───────────┬──────────────────────────────────┬─────────────────────┘
            │                                  │
    ┌───────▼────────┐                ┌───────▼────────┐
    │ Chat Service   │                │ Chat Service   │
    │  Instance 1    │                │  Instance 2    │
    │                │                │                │
    │ WebSocket      │                │ WebSocket      │
    │ Handler        │                │ Handler        │
    │                │                │                │
    │ ┌──────────────┴────────────────┴──────────────┐ │
    │ │           Redis Pub/Sub Channel               │ │
    │ │         (chat.messages.{orderId})             │ │
    │ └──────────────┬────────────────┬──────────────┘ │
    │                │                │                │
    │          ┌─────▼──────┐   ┌─────▼──────┐        │
    │          │  MongoDB   │   │  MongoDB   │        │
    │          │ (Primary)  │   │ (Replica)  │        │
    │          └────────────┘   └────────────┘        │
    └────────────────────────────────────────────────────┘

                      ┌────────────┐
                      │   Kafka    │
                      │  (Events)  │
                      └─────┬──────┘
                            │
                    ┌───────▼────────┐
                    │ Event Consumer │
                    │ (Order events) │
                    └────────────────┘
```

---

## 4. Fluxo de Comunicação Detalhado

### 4.1 Conexão WebSocket

#### **Cliente**

```javascript
// React - ChatService.js
import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';

class ChatService {
  constructor() {
    this.stompClient = null;
  }

  connect(orderId, onMessageReceived) {
    const socket = new SockJS('http://localhost:8080/ws/chat');
    
    this.stompClient = new Client({
      webSocketFactory: () => socket,
      debug: (str) => console.log(str),
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
    });

    this.stompClient.onConnect = () => {
      console.log('Connected to WebSocket');
      
      // Subscribe to chat topic
      this.stompClient.subscribe(
        `/topic/chat/${orderId}`,
        (message) => {
          const parsedMessage = JSON.parse(message.body);
          onMessageReceived(parsedMessage);
        }
      );
    };

    this.stompClient.activate();
  }

  sendMessage(orderId, content) {
    if (this.stompClient && this.stompClient.connected) {
      const message = {
        orderId: orderId,
        content: content,
        timestamp: new Date().toISOString()
      };

      this.stompClient.publish({
        destination: '/app/chat.send',
        body: JSON.stringify(message)
      });
    }
  }

  disconnect() {
    if (this.stompClient) {
      this.stompClient.deactivate();
    }
  }
}

export default new ChatService();
```

#### **Backend - Spring Boot Configuration**

```java
// WebSocketConfig.java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // Enable simple broker for /topic
        config.enableSimpleBroker("/topic");
        
        // Set application destination prefix
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

### 4.2 Envio de Mensagem

```java
// ChatController.java
@Controller
public class ChatController {

    @Autowired
    private ChatService chatService;

    @Autowired
    private RedisMessagePublisher redisPublisher;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload ChatMessageDTO messageDTO, 
                           SimpMessageHeaderAccessor headerAccessor) {
        
        // 1. Get sender info from session
        String userId = (String) headerAccessor.getSessionAttributes().get("userId");
        
        // 2. Build message entity
        ChatMessage message = ChatMessage.builder()
                .orderId(messageDTO.getOrderId())
                .senderId(userId)
                .senderName(messageDTO.getSenderName())
                .senderType(messageDTO.getSenderType())
                .content(messageDTO.getContent())
                .messageType(MessageType.TEXT)
                .createdAt(LocalDateTime.now())
                .build();
        
        // 3. Save to MongoDB (asynchronously)
        chatService.saveMessage(message);
        
        // 4. Publish to Redis Pub/Sub for multi-instance sync
        String channel = "chat.messages." + messageDTO.getOrderId();
        redisPublisher.publish(channel, message);
        
        // Note: Redis subscriber will handle WebSocket broadcast
    }
}
```

### 4.3 Multi-instância com Redis Pub/Sub

#### **Publisher**

```java
// RedisMessagePublisher.java
@Service
public class RedisMessagePublisher {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    public void publish(String channel, Object message) {
        redisTemplate.convertAndSend(channel, message);
    }
}
```

#### **Subscriber**

```java
// RedisMessageSubscriber.java
@Service
public class RedisMessageSubscriber implements MessageListener {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Override
    public void onMessage(Message message, byte[] pattern) {
        // 1. Deserialize message
        ChatMessage chatMessage = deserialize(message.getBody());
        
        // 2. Extract orderId from channel
        String channel = new String(message.getChannel());
        String orderId = channel.replace("chat.messages.", "");
        
        // 3. Broadcast to WebSocket subscribers
        messagingTemplate.convertAndSend(
            "/topic/chat/" + orderId, 
            chatMessage
        );
    }
    
    private ChatMessage deserialize(byte[] body) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(body, ChatMessage.class);
        } catch (IOException e) {
            throw new RuntimeException("Error deserializing message", e);
        }
    }
}
```

#### **Redis Configuration**

```java
// RedisConfig.java
@Configuration
public class RedisConfig {

    @Bean
    RedisMessageListenerContainer container(RedisConnectionFactory connectionFactory,
                                           MessageListenerAdapter listenerAdapter) {
        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        
        // Subscribe to pattern (all chat channels)
        container.addMessageListener(
            listenerAdapter, 
            new PatternTopic("chat.messages.*")
        );
        
        return container;
    }

    @Bean
    MessageListenerAdapter listenerAdapter(RedisMessageSubscriber subscriber) {
        return new MessageListenerAdapter(subscriber, "onMessage");
    }

    @Bean
    RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        return template;
    }
}
```

---

## 5. Integração com Kafka (Mensagens Automáticas)

### 5.1 Consumindo Eventos de Pedido

```java
// OrderEventConsumer.java
@Service
public class OrderEventConsumer {

    @Autowired
    private ChatService chatService;

    @KafkaListener(topics = "order.status.changed", groupId = "chat-service")
    public void handleOrderStatusChanged(OrderStatusChangedEvent event) {
        
        // Create system message
        ChatMessage systemMessage = ChatMessage.builder()
                .orderId(event.getOrderId())
                .senderId("SYSTEM")
                .senderName("Sistema")
                .senderType(SenderType.SYSTEM)
                .content(buildStatusMessage(event.getNewStatus()))
                .messageType(MessageType.SYSTEM)
                .metadata(Map.of("statusChange", event.getNewStatus()))
                .createdAt(LocalDateTime.now())
                .build();
        
        // Save and broadcast
        chatService.sendSystemMessage(systemMessage);
    }

    @KafkaListener(topics = "delivery.assigned", groupId = "chat-service")
    public void handleDeliveryAssigned(DeliveryAssignedEvent event) {
        
        // Add delivery person to chat
        chatService.addParticipant(
            event.getOrderId(),
            event.getDeliveryPersonId(),
            event.getDeliveryPersonName(),
            SenderType.DELIVERY_PERSON
        );
        
        // Send welcome message
        ChatMessage welcomeMessage = ChatMessage.builder()
                .orderId(event.getOrderId())
                .senderId("SYSTEM")
                .senderName("Sistema")
                .senderType(SenderType.SYSTEM)
                .content(event.getDeliveryPersonName() + " entrou na conversa")
                .messageType(MessageType.SYSTEM)
                .createdAt(LocalDateTime.now())
                .build();
        
        chatService.sendSystemMessage(welcomeMessage);
    }

    private String buildStatusMessage(String status) {
        return switch (status) {
            case "ACCEPTED" -> "✅ Pedido aceito! Estamos preparando...";
            case "IN_PREPARATION" -> "👨‍🍳 Seu pedido está sendo preparado";
            case "READY" -> "✅ Pedido pronto!";
            case "OUT_FOR_DELIVERY" -> "🚗 Pedido saiu para entrega";
            case "DELIVERED" -> "✅ Pedido entregue! Obrigado!";
            default -> "Status atualizado: " + status;
        };
    }
}
```

---

## 6. Modelo de Dados (MongoDB)

### 6.1 Chat Document

```java
// Chat.java
@Document(collection = "chats")
@Data
@Builder
public class Chat {
    
    @Id
    private String id;
    
    @Indexed(unique = true)
    private String orderId;
    
    private List<Participant> participants;
    
    @Indexed
    private ChatStatus status; // ACTIVE, ARCHIVED
    
    private LocalDateTime createdAt;
    private LocalDateTime lastMessageAt;
    private LocalDateTime archivedAt;
}

// Participant.java
@Data
@Builder
public class Participant {
    private String userId;
    private String name;
    private SenderType type; // STORE, CUSTOMER, DELIVERY_PERSON
    private LocalDateTime joinedAt;
}
```

### 6.2 Message Document

```java
// ChatMessage.java
@Document(collection = "messages")
@Data
@Builder
public class ChatMessage {
    
    @Id
    private String id;
    
    @Indexed
    private String chatId; // Reference to Chat
    
    @Indexed
    private String orderId; // For faster queries
    
    @Indexed
    private String senderId;
    private String senderName;
    private SenderType senderType;
    
    private String content;
    private MessageType messageType; // TEXT, IMAGE, SYSTEM
    
    private Map<String, Object> metadata; // Additional info
    
    private List<ReadReceipt> readBy;
    
    @Indexed
    private LocalDateTime createdAt;
}

// ReadReceipt.java
@Data
@Builder
public class ReadReceipt {
    private String userId;
    private LocalDateTime readAt;
}
```

---

## 7. Otimizações e Boas Práticas

### 7.1 Paginação de Mensagens

```java
// ChatService.java
public Page<ChatMessage> getMessageHistory(String orderId, int page, int size) {
    Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
    return messageRepository.findByOrderId(orderId, pageable);
}
```

### 7.2 Limpeza de Chats Antigos

```java
// ChatCleanupScheduler.java
@Component
public class ChatCleanupScheduler {

    @Autowired
    private ChatRepository chatRepository;

    @Scheduled(cron = "0 0 2 * * ?") // Diariamente às 2h
    public void archiveOldChats() {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(30);
        
        List<Chat> oldChats = chatRepository.findByStatusAndLastMessageAtBefore(
            ChatStatus.ACTIVE, 
            cutoffDate
        );
        
        oldChats.forEach(chat -> {
            chat.setStatus(ChatStatus.ARCHIVED);
            chat.setArchivedAt(LocalDateTime.now());
        });
        
        chatRepository.saveAll(oldChats);
    }
}
```

### 7.3 Monitoring de Conexões

```java
// WebSocketEventListener.java
@Component
public class WebSocketEventListener {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        logger.info("New WebSocket connection established");
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        logger.info("WebSocket connection closed");
    }
}
```

### 7.4 Rate Limiting

```java
// RateLimitingInterceptor.java
@Component
public class RateLimitingInterceptor implements ChannelInterceptor {

    private final Bucket bucket = Bucket.builder()
        .addLimit(Bandwidth.classic(10, Refill.intervally(10, Duration.ofSeconds(1))))
        .build();

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        if (bucket.tryConsume(1)) {
            return message;
        } else {
            throw new RateLimitExceededException("Too many messages");
        }
    }
}
```

---

## 8. Testes

### 8.1 Teste de Chat Service

```java
@SpringBootTest
@AutoConfigureMockMvc
public class ChatServiceTest {

    @Autowired
    private ChatService chatService;

    @MockBean
    private MessageRepository messageRepository;

    @Test
    public void testSendMessage() {
        // Given
        ChatMessage message = ChatMessage.builder()
                .orderId("123")
                .content("Test message")
                .senderId("user1")
                .build();

        // When
        chatService.saveMessage(message);

        // Then
        verify(messageRepository, times(1)).save(any(ChatMessage.class));
    }
}
```

### 8.2 Teste WebSocket (Integration)

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class ChatWebSocketTest {

    @LocalServerPort
    private int port;

    private StompSession stompSession;

    @BeforeEach
    public void setup() throws Exception {
        WebSocketStompClient stompClient = new WebSocketStompClient(
            new SockJsClient(List.of(new WebSocketTransport(new StandardWebSocketClient())))
        );
        stompClient.setMessageConverter(new MappingJackson2MessageConverter());

        String url = "ws://localhost:" + port + "/ws/chat";
        stompSession = stompClient.connect(url, new StompSessionHandlerAdapter() {}).get();
    }

    @Test
    public void testSendAndReceiveMessage() throws Exception {
        CompletableFuture<ChatMessage> future = new CompletableFuture<>();

        stompSession.subscribe("/topic/chat/123", new StompFrameHandler() {
            @Override
            public Type getPayloadType(StompHeaders headers) {
                return ChatMessage.class;
            }

            @Override
            public void handleFrame(StompHeaders headers, Object payload) {
                future.complete((ChatMessage) payload);
            }
        });

        ChatMessage message = new ChatMessage();
        message.setOrderId("123");
        message.setContent("Test");

        stompSession.send("/app/chat.send", message);

        ChatMessage received = future.get(5, TimeUnit.SECONDS);
        assertThat(received.getContent()).isEqualTo("Test");
    }
}
```

---

## 9. Métricas e Monitoramento

### 9.1 Métricas Importantes

- **Conexões WebSocket ativas**
- **Mensagens enviadas/recebidas por segundo**
- **Latência de entrega de mensagens**
- **Taxa de erro de conexão**
- **Uso de memória (conexões)**

### 9.2 Configuração Prometheus

```java
@Configuration
public class MetricsConfig {

    @Bean
    public MeterRegistryCustomizer<MeterRegistry> metricsCommonTags() {
        return registry -> registry.config().commonTags("application", "chat-service");
    }
}
```

---

## 10. Conceitos Acadêmicos Aplicados

### 10.1 Mensageria e Streams

| **Conceito** | **Aplicação no Projeto** |
|--------------|--------------------------|
| **Publish/Subscribe** | Redis Pub/Sub para sincronização multi-instância |
| **Event-Driven Architecture** | Kafka para eventos de pedido |
| **Message Broker** | Redis como broker de mensagens em tempo real |
| **Stream Processing** | Processamento de eventos de status de pedido |
| **Message Persistence** | MongoDB para histórico de mensagens |

### 10.2 Protocolos e Padrões

- **WebSocket**: Comunicação bidirecional full-duplex
- **STOMP**: Protocolo de mensageria sobre WebSocket
- **Pub/Sub Pattern**: Desacoplamento de produtores e consumidores
- **Event Sourcing**: Histórico completo de mensagens

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
