package br.com.logdash.backend.communication.domain.repository;

import br.com.logdash.backend.communication.domain.model.Message;

import java.util.List;

public interface MessageRepository {
    Message save(Message message);
    List<Message> findByOrderId(Long orderId);
    List<Message> findByChannelId(Long channelId);
}
