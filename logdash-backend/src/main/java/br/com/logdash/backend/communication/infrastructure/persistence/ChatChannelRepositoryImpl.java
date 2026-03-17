package br.com.logdash.backend.communication.infrastructure.persistence;

import br.com.logdash.backend.communication.domain.model.ChatChannel;
import br.com.logdash.backend.communication.domain.repository.ChatChannelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChatChannelRepositoryImpl implements ChatChannelRepository {

    private final ChatChannelJpaRepository jpaRepository;

    @Override
    public ChatChannel save(ChatChannel channel) {
        return jpaRepository.save(channel);
    }

    @Override
    public Optional<ChatChannel> findByOrderId(Long orderId) {
        return jpaRepository.findByOrderId(orderId);
    }
}
