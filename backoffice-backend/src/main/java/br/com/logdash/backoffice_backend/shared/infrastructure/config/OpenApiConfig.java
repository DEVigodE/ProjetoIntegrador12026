package br.com.logdash.backoffice_backend.shared.infrastructure.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri}")
    private String issuerUri;

    @Bean
    public OpenAPI customOpenAPI() {
        final String oauthSchemeName = "oauth2";

        String authUrl   = issuerUri + "/protocol/openid-connect/auth";
        String tokenUrl  = issuerUri + "/protocol/openid-connect/token";

        Scopes scopes = new Scopes()
                .addString("openid", "OpenID Connect")
                .addString("profile", "Perfil do usuário")
                .addString("email", "Email do usuário");

        return new OpenAPI()
                .info(new Info()
                        .title("Logdash Backoffice API")
                        .description("API do Backoffice para Delivery de Alimentos")
                        .version("1.0.1")
                        .contact(new Contact()
                                .name("Logdash")
                                .email("contato@logdash.com.br")))
                .addSecurityItem(new SecurityRequirement().addList(oauthSchemeName))
                .components(new Components()
                        .addSecuritySchemes(oauthSchemeName,
                                new SecurityScheme()
                                        .name(oauthSchemeName)
                                        .type(SecurityScheme.Type.OAUTH2)
                                        .flows(new OAuthFlows()
                                                .authorizationCode(new OAuthFlow()
                                                        .authorizationUrl(authUrl)
                                                        .tokenUrl(tokenUrl)
                                                        .scopes(scopes)))));
    }
}
