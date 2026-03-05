package br.com.logdash.backoffice_backend.shared.infrastructure.config;

import org.flywaydb.core.Flyway;
import org.springframework.boot.hibernate.autoconfigure.HibernatePropertiesCustomizer;
import org.springframework.boot.sql.init.dependency.DependsOnDatabaseInitialization;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class DatabaseConfig {

    @Bean(initMethod = "migrate")
    public Flyway flyway(DataSource dataSource) {
        return Flyway.configure()
                .dataSource(dataSource)
                .locations("classpath:db/migration")
                .load();
    }

    /**
     * Garante que o EntityManagerFactory do Hibernate só seja criado
     * DEPOIS que o Flyway terminar de rodar as migrations.
     */
    @Bean
    @DependsOnDatabaseInitialization
    @SuppressWarnings("unused")
    public HibernatePropertiesCustomizer flywayOrderGuarantee(Flyway flyway) {
        return hibernateProperties -> { /* no-op: força a ordem de inicialização via dependência no bean flyway */ };
    }
}
