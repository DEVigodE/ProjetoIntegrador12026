package br.com.logdash.backend.communication.domain.model;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "messages", schema = "communication_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
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
    private String senderId;

    @Column(name = "sender_type", nullable = false, length = 50)
    private String senderType;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "sent_at", nullable = false)
    private LocalDateTime sentAt;

    @Column(name = "read_at")
    private LocalDateTime readAt;

    public static Message create(ChatChannel channel, Long orderId,
                                  String senderId, String senderType, String content) {
        Message message = new Message();
        message.channel = channel;
        message.orderId = orderId;
        message.senderId = senderId;
        message.senderType = senderType;
        message.content = content;
        message.sentAt = LocalDateTime.now();
        return message;
    }

    public void markAsRead() {
        this.readAt = LocalDateTime.now();
    }
}
