package br.com.logdash.backend.communication.application.service;

import br.com.logdash.backend.communication.application.dto.ChatChannelResponse;
import br.com.logdash.backend.communication.application.dto.MessageResponse;
import br.com.logdash.backend.communication.application.dto.SendMessageRequest;
import br.com.logdash.backend.communication.domain.model.ChatChannel;
import br.com.logdash.backend.communication.domain.model.Message;
import br.com.logdash.backend.communication.domain.repository.ChatChannelRepository;
import br.com.logdash.backend.communication.domain.repository.MessageRepository;
import br.com.logdash.backend.shared.application.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatApplicationService {

    private final ChatChannelRepository chatChannelRepository;
    private final MessageRepository messageRepository;

    @Transactional
    public ChatChannelResponse createChannel(Long orderId) {
        ChatChannel channel = ChatChannel.create(orderId);
        channel = chatChannelRepository.save(channel);
        return ChatChannelResponse.from(channel);
    }

    @Transactional(readOnly = true)
    public ChatChannelResponse getChannel(Long orderId) {
        ChatChannel channel = chatChannelRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Canal de chat não encontrado para o pedido: " + orderId));
        return ChatChannelResponse.from(channel);
    }

    @Transactional
    public MessageResponse sendMessage(Long orderId, SendMessageRequest request) {
        ChatChannel channel = chatChannelRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Canal de chat não encontrado para o pedido: " + orderId));

        Message message = Message.create(
                channel,
                orderId,
                request.getSenderId(),
                request.getSenderType(),
                request.getContent()
        );
        message = messageRepository.save(message);
        return MessageResponse.from(message);
    }

    @Transactional
    public MessageResponse sendSystemMessage(Long orderId, String content) {
        ChatChannel channel = chatChannelRepository.findByOrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Canal de chat não encontrado para o pedido: " + orderId));

        Message message = Message.create(channel, orderId, "SYSTEM", "SYSTEM", content);
        message = messageRepository.save(message);
        return MessageResponse.from(message);
    }

    @Transactional(readOnly = true)
    public List<MessageResponse> getMessages(Long orderId) {
        return messageRepository.findByOrderId(orderId).stream()
                .map(MessageResponse::from)
                .collect(Collectors.toList());
    }
}
