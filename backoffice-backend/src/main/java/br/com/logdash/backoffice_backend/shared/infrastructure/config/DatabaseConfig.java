package br.com.logdash.backoffice_backend.shared.infrastructure.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class DatabaseConfig {
    // PostgreSQL datasource is configured via application.yaml
    // Flyway handles schema creation and migrations
}
