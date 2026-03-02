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
- **Histórico Persistente**: Todas as mensagens armazenadas no PostgreSQL via JPA
- **Mensagens do Sistema**: Automáticas ao mudar status do pedido
- **Notificações Visuais**: Indicador de novas mensagens
- **Escalabilidade**: Suporte a múltiplas instâncias do serviço

### 2.2 Desafios Técnicos

1. **Persistência + Tempo Real**: Como garantir que mensagens sejam salvas E entregues instantaneamente?
2. **Conexões WebSocket**: Como gerenciar conexões ativas simultâneas?
3. **Garantia de Entrega**: Como garantir que mensagens não se percam?
4. **Eventos de Pedido**: Como enviar mensagens automáticas ao mudar o status do pedido?

---

## 3. Arquitetura da Solução

### 3.1 Stack Tecnológica

| **Componente** | **Tecnologia** | **Justificativa** |
|----------------|----------------|-------------------|
| Protocolo | WebSocket + STOMP | Bidirecional, baixa latência, padrão da indústria |
| Backend | Spring Boot + WebSocket | Integração nativa, fácil configuração |
| Message Broker | Spring Simple Broker (in-memory) | Integração nativa Spring, ideal para monolito modular |
| Persistência | PostgreSQL (JPA) + Spring Data | Banco único, ACID, consistência total |
| Cliente | SockJS + StompJS | Fallback automático, compatibilidade |

### 3.2 Arquitetura Detalhada

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
│                                                                      │
│  ┌──────────────────┐              ┌──────────────────┐            │
│  │  Store Client    │              │ Customer Client  │            │
│  │   (React App)    │              │   (Mobile App)   │            │
│  │ - SockJS Client  │              │ - SockJS Client  │            │
│  │ - STOMP Client   │              │ - STOMP Client   │            │
│  │ - Chat Component │              │ - Chat Component │            │
│  └────────┬─────────┘              └────────┬─────────┘            │
└───────────┼──────────────────────────────────┼─────────────────────┘
            │ WS/WSS /ws/chat                  │
            │                                  │
┌───────────▼──────────────────────────────────▼─────────────────────┐
│                  SPRING BOOT MONOLITO MODULAR                        │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │               WebSocket Handler (STOMP)                     │    │
│  │  - ChatController  (@MessageMapping "/chat.send")           │    │
│  │  - SimpMessagingTemplate  (broadcast → /topic/chat/{id})    │    │
│  └─────────────────────────┬──────────────────────────────────┘    │
│                             │                                        │
│  ┌──────────────────────────▼──────────────────────────────────┐   │
│  │              Communication Service (JPA)                      │   │
│  │  - ChatChannelService  (abrir / fechar canais)               │   │
│  │  - MessageService      (salvar / recuperar mensagens)        │   │
│  └─────────────────────────┬──────────────────────────────────┘    │
│                             │                                        │
│  ┌──────────────────────────▼──────────────────────────────────┐   │
│  │          Spring Events  (ApplicationEventPublisher)           │   │
│  │  - OrderStatusChangedEvent → mensagens automáticas do sistema│   │
│  │  - DeliveryAssignedEvent   → adiciona entregador ao canal    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
              ┌───────────────▼────────────────┐
              │   PostgreSQL — communication    │
              │   ┌─────────────────────────┐  │
              │   │  chat_channels          │  │
              │   │  chat_participants      │  │
              │   │  messages               │  │
              │   └─────────────────────────┘  │
              └────────────────────────────────┘
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
    private MessageService messageService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload ChatMessageDTO messageDTO,
                            SimpMessageHeaderAccessor headerAccessor) {

        // 1. Get sender info from session
        String userId = (String) headerAccessor.getSessionAttributes().get("userId");

        // 2. Persist message via JPA (PostgreSQL)
        Message saved = messageService.save(Message.builder()
                .channelId(messageDTO.getChannelId())
                .orderId(messageDTO.getOrderId())
                .senderId(userId)
                .senderType(messageDTO.getSenderType())
                .content(messageDTO.getContent())
                .sentAt(LocalDateTime.now())
                .build());

        // 3. Broadcast directly via Spring Simple Broker
        messagingTemplate.convertAndSend(
                "/topic/chat/" + messageDTO.getOrderId(),
                saved);
    }
}
```

### 4.3 Persistência JPA e Broadcast via Spring Simple Broker

```java
// MessageService.java
@Service
@Transactional
public class MessageService {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private ChatChannelRepository channelRepository;

    public Message save(Message message) {
        // Validate channel exists and is active
        ChatChannel channel = channelRepository.findById(message.getChannelId())
                .orElseThrow(() -> new NotFoundException("Channel not found"));

        if (!channel.isActive()) {
            throw new BusinessException("Chat channel is closed");
        }

        return messageRepository.save(message);
    }

    @Transactional(readOnly = true)
    public Page<Message> getHistory(Long channelId, Pageable pageable) {
        return messageRepository.findByChannelIdOrderBySentAtDesc(channelId, pageable);
    }
}
```

```java
// MessageRepository.java
@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    Page<Message> findByChannelIdOrderBySentAtDesc(Long channelId, Pageable pageable);
    List<Message> findByChannelIdAndReadAtIsNull(Long channelId);
}
```

---

## 5. Integração com Spring Events (Mensagens Automáticas)

### 5.1 Consumindo Eventos de Domínio

```java
// ChatEventListener.java
@Component
public class ChatEventListener {

    @Autowired
    private ChatService chatService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleOrderStatusChanged(OrderStatusChangedEvent event) {

        // Create and persist system message
        Message systemMessage = Message.builder()
                .orderId(event.getOrderId())
                .senderId("SYSTEM")
                .senderType(SenderType.SYSTEM)
                .content(buildStatusMessage(event.getNewStatus()))
                .sentAt(LocalDateTime.now())
                .build();

        Message saved = chatService.sendSystemMessage(systemMessage);

        // Broadcast to WebSocket subscribers
        messagingTemplate.convertAndSend(
                "/topic/chat/" + event.getOrderId(), saved);
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleDeliveryAssigned(DeliveryAssignedEvent event) {

        // Add delivery person to channel participants
        chatService.addParticipant(
                event.getOrderId(),
                event.getDeliveryPersonId(),
                SenderType.DELIVERY_PERSON);

        // Send welcome system message
        Message welcomeMessage = Message.builder()
                .orderId(event.getOrderId())
                .senderId("SYSTEM")
                .senderType(SenderType.SYSTEM)
                .content(event.getDeliveryPersonName() + " entrou na conversa")
                .sentAt(LocalDateTime.now())
                .build();

        Message saved = chatService.sendSystemMessage(welcomeMessage);
        messagingTemplate.convertAndSend("/topic/chat/" + event.getOrderId(), saved);
    }

    private String buildStatusMessage(String status) {
        return switch (status) {
            case "ACCEPTED"         -> "✅ Pedido aceito! Estamos preparando...";
            case "IN_PREPARATION"   -> "👨‍🍳 Seu pedido está sendo preparado";
            case "READY"            -> "✅ Pedido pronto!";
            case "OUT_FOR_DELIVERY" -> "🚗 Pedido saiu para entrega";
            case "DELIVERED"        -> "✅ Pedido entregue! Obrigado!";
            default                 -> "Status atualizado: " + status;
        };
    }
}
```

---

## 6. Modelo de Dados (PostgreSQL / JPA)

### 6.1 Entidade ChatChannel

```java
// ChatChannel.java
@Entity
@Table(name = "chat_channels", schema = "communication")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatChannel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false, unique = true)
    private Long orderId;

    @Column(nullable = false)
    private boolean active;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "channel", cascade = CascadeType.ALL)
    private List<ChatParticipant> participants;

    @OneToMany(mappedBy = "channel", cascade = CascadeType.ALL)
    private List<Message> messages;
}

// ChatParticipant.java
@Entity
@Table(name = "chat_participants", schema = "communication")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatParticipant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "channel_id", nullable = false)
    private ChatChannel channel;

    @Column(name = "participant_id", nullable = false)
    private Long participantId;

    @Enumerated(EnumType.STRING)
    @Column(name = "participant_type", nullable = false)
    private SenderType participantType; // STORE, CUSTOMER, DELIVERY_PERSON

    @Column(name = "joined_at", nullable = false)
    private LocalDateTime joinedAt;
}
```

### 6.2 Entidade Message

```java
// Message.java
@Entity
@Table(name = "messages", schema = "communication")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "channel_id", nullable = false)
    private ChatChannel channel;

    @Column(name = "order_id", nullable = false)
    private Long orderId;

    @Column(name = "sender_id", nullable = false)
    private Long senderId;

    @Enumerated(EnumType.STRING)
    @Column(name = "sender_type", nullable = false)
    private SenderType senderType; // STORE, CUSTOMER, DELIVERY_PERSON, SYSTEM

    @Column(nullable = false, length = 2000)
    private String content;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;
}
```

---

## 7. Otimizações e Boas Práticas

### 7.1 Paginação de Mensagens

```java
// ChatService.java
public Page<Message> getMessageHistory(Long channelId, int page, int size) {
    Pageable pageable = PageRequest.of(page, size, Sort.by("sentAt").descending());
    return messageRepository.findByChannelIdOrderBySentAtDesc(channelId, pageable);
}
```

### 7.2 Limpeza de Chats Antigos

```java
// ChatCleanupScheduler.java
@Component
public class ChatCleanupScheduler {

    @Autowired
    private ChatChannelRepository channelRepository;

    @Scheduled(cron = "0 0 2 * * ?") // Diariamente às 2h
    @Transactional
    public void archiveOldChannels() {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(30);

        List<ChatChannel> oldChannels = channelRepository
                .findByActiveTrueAndCreatedAtBefore(cutoffDate);

        oldChannels.forEach(channel -> channel.setActive(false));

        channelRepository.saveAll(oldChannels);
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
@ExtendWith(MockitoExtension.class)
public class MessageServiceTest {

    @Mock
    private MessageRepository messageRepository;

    @Mock
    private ChatChannelRepository channelRepository;

    @InjectMocks
    private MessageService messageService;

    @Test
    public void shouldSaveMessageSuccessfully() {
        // Given
        ChatChannel channel = ChatChannel.builder()
                .id(1L).orderId(10L).active(true).build();
        Message message = Message.builder()
                .channelId(1L).content("Test message").senderId(99L).build();

        when(channelRepository.findById(1L)).thenReturn(Optional.of(channel));
        when(messageRepository.save(any())).thenReturn(message);

        // When
        messageService.save(message);

        // Then
        verify(messageRepository, times(1)).save(any(Message.class));
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
                return Message.class;
            }

            @Override
            public void handleFrame(StompHeaders headers, Object payload) {
                future.complete((Message) payload);
            }
        });

        ChatMessageDTO message = new ChatMessageDTO();
        message.setOrderId(10L);
        message.setContent("Test");

        stompSession.send("/app/chat.send", message);

        Message received = future.get(5, TimeUnit.SECONDS);
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
| **Publish/Subscribe** | Spring Simple Broker para broadcast WebSocket |
| **Event-Driven Architecture** | Spring Events (`ApplicationEventPublisher`) para eventos de pedido |
| **Message Broker** | Spring Simple Broker (in-memory) nativo do Spring |
| **Stream Processing** | `@TransactionalEventListener` processando eventos de domínio |
| **Message Persistence** | PostgreSQL (JPA) para histórico completo de mensagens |

### 10.2 Protocolos e Padrões

- **WebSocket**: Comunicação bidirecional full-duplex
- **STOMP**: Protocolo de mensageria sobre WebSocket
- **Pub/Sub Pattern**: Desacoplamento de produtores e consumidores
- **Event Sourcing**: Histórico completo de mensagens

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
