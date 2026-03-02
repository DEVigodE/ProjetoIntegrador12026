package br.com.logdash.backoffice_backend.communication.domain.repository;

import br.com.logdash.backoffice_backend.communication.domain.model.ChatChannel;

import java.util.Optional;

public interface ChatChannelRepository {
    ChatChannel save(ChatChannel channel);
    Optional<ChatChannel> findByOrderId(Long orderId);
}
