package br.com.logdash.backoffice_backend.communication.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SendMessageRequest {

    @NotBlank(message = "ID do remetente é obrigatório")
    private String senderId;

    @NotBlank(message = "Tipo do remetente é obrigatório")
    private String senderType;

    @NotBlank(message = "Conteúdo da mensagem é obrigatório")
    private String content;
}
