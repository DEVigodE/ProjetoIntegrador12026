package br.com.logdash.backoffice_backend.communication.infrastructure.persistence;

import br.com.logdash.backoffice_backend.communication.domain.model.ChatChannel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ChatChannelJpaRepository extends JpaRepository<ChatChannel, Long> {
    Optional<ChatChannel> findByOrderId(Long orderId);
}
