package br.com.logdash.backoffice_backend.communication.application.dto;

import br.com.logdash.backoffice_backend.communication.domain.model.Message;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageResponse {

    private Long id;
    private Long channelId;
    private Long orderId;
    private String senderId;
    private String senderType;
    private String content;
    private LocalDateTime sentAt;
    private LocalDateTime readAt;

    public static MessageResponse from(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .channelId(message.getChannel().getId())
                .orderId(message.getOrderId())
                .senderId(message.getSenderId())
                .senderType(message.getSenderType())
                .content(message.getContent())
                .sentAt(message.getSentAt())
                .readAt(message.getReadAt())
                .build();
    }
}
