package br.com.logdash.backoffice_backend.communication.domain.valueobject;

import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Participant {
    private String participantId;

    @Enumerated(EnumType.STRING)
    private ParticipantType participantType;
}
