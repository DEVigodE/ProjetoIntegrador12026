package br.com.logdash.backoffice_backend.communication.infrastructure.persistence;

import br.com.logdash.backoffice_backend.communication.domain.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageJpaRepository extends JpaRepository<Message, Long> {

    @Query("SELECT m FROM Message m WHERE m.orderId = :orderId ORDER BY m.sentAt ASC")
    List<Message> findByOrderIdOrderBySentAtAsc(@Param("orderId") Long orderId);

    @Query("SELECT m FROM Message m WHERE m.channel.id = :channelId ORDER BY m.sentAt ASC")
    List<Message> findByChannelIdOrderBySentAtAsc(@Param("channelId") Long channelId);
}
