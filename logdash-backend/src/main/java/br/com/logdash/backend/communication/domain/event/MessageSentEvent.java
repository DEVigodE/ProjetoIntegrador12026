package br.com.logdash.backend.communication.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class MessageSentEvent extends DomainEvent {
    private final Long messageId;
    private final Long channelId;
    private final Long orderId;

    public MessageSentEvent(Long messageId, Long channelId, Long orderId) {
        super();
        this.messageId = messageId;
        this.channelId = channelId;
        this.orderId = orderId;
    }
}
