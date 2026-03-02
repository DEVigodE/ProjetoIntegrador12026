package br.com.logdash.backoffice_backend.communication.presentation.controller;

import br.com.logdash.backoffice_backend.communication.application.dto.ChatChannelResponse;
import br.com.logdash.backoffice_backend.communication.application.dto.MessageResponse;
import br.com.logdash.backoffice_backend.communication.application.service.ChatApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatApplicationService chatApplicationService;

    @GetMapping("/{orderId}/messages")
    public List<MessageResponse> getMessages(@PathVariable Long orderId) {
        return chatApplicationService.getMessages(orderId);
    }

    @GetMapping("/{orderId}")
    public ChatChannelResponse getChannel(@PathVariable Long orderId) {
        return chatApplicationService.getChannel(orderId);
    }
}
