package br.com.logdash.backoffice_backend.communication.domain.repository;

import br.com.logdash.backoffice_backend.communication.domain.model.Message;

import java.util.List;

public interface MessageRepository {
    Message save(Message message);
    List<Message> findByOrderId(Long orderId);
    List<Message> findByChannelId(Long channelId);
}
