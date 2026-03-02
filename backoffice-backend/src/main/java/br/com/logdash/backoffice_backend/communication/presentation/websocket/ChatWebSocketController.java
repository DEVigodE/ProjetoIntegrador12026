package br.com.logdash.backoffice_backend.communication.presentation.websocket;

import br.com.logdash.backoffice_backend.communication.application.dto.MessageResponse;
import br.com.logdash.backoffice_backend.communication.application.dto.SendMessageRequest;
import br.com.logdash.backoffice_backend.communication.application.service.ChatApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatApplicationService chatApplicationService;

    @MessageMapping("/chat/{orderId}/send")
    @SendTo("/topic/chat/{orderId}")
    public MessageResponse sendMessage(
            @DestinationVariable Long orderId,
            SendMessageRequest request) {
        return chatApplicationService.sendMessage(orderId, request);
    }
}
