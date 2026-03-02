package br.com.logdash.backoffice_backend.communication.infrastructure.persistence;

import br.com.logdash.backoffice_backend.communication.domain.model.Message;
import br.com.logdash.backoffice_backend.communication.domain.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class MessageRepositoryImpl implements MessageRepository {

    private final MessageJpaRepository jpaRepository;

    @Override
    public Message save(Message message) {
        return jpaRepository.save(message);
    }

    @Override
    public List<Message> findByOrderId(Long orderId) {
        return jpaRepository.findByOrderIdOrderBySentAtAsc(orderId);
    }

    @Override
    public List<Message> findByChannelId(Long channelId) {
        return jpaRepository.findByChannelIdOrderBySentAtAsc(channelId);
    }
}
