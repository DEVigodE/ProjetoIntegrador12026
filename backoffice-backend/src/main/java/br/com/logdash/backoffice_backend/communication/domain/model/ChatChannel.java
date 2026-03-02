package br.com.logdash.backoffice_backend.communication.domain.model;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.AbstractAggregateRoot;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "chat_channels", schema = "communication_schema")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ChatChannel extends AbstractAggregateRoot<ChatChannel> {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false, unique = true)
    private Long orderId;

    @Column(nullable = false)
    private boolean active = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "channel", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Message> messages = new ArrayList<>();

    public static ChatChannel create(Long orderId) {
        ChatChannel channel = new ChatChannel();
        channel.orderId = orderId;
        channel.active = true;
        channel.createdAt = LocalDateTime.now();
        return channel;
    }

    public void close() {
        this.active = false;
    }
}
