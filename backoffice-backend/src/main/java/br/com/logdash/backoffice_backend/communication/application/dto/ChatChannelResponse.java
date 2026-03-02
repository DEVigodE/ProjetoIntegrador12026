package br.com.logdash.backoffice_backend.communication.application.dto;

import br.com.logdash.backoffice_backend.communication.domain.model.ChatChannel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatChannelResponse {

    private Long id;
    private Long orderId;
    private boolean active;
    private LocalDateTime createdAt;

    public static ChatChannelResponse from(ChatChannel channel) {
        return ChatChannelResponse.builder()
                .id(channel.getId())
                .orderId(channel.getOrderId())
                .active(channel.isActive())
                .createdAt(channel.getCreatedAt())
                .build();
    }
}
