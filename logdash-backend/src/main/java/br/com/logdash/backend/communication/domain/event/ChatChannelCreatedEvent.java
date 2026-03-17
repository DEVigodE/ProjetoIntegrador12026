package br.com.logdash.backend.communication.domain.event;

import br.com.logdash.backend.shared.domain.DomainEvent;
import lombok.Getter;

@Getter
public class ChatChannelCreatedEvent extends DomainEvent {
    private final Long channelId;
    private final Long orderId;

    public ChatChannelCreatedEvent(Long channelId, Long orderId) {
        super();
        this.channelId = channelId;
        this.orderId = orderId;
    }
}
