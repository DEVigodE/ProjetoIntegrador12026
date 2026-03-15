package br.com.logdash.backoffice_backend.shared.infrastructure.config;

import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.hibernate.autoconfigure.HibernatePropertiesCustomizer;
import org.springframework.boot.sql.init.dependency.DependsOnDatabaseInitialization;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.util.List;

@Configuration
public class DatabaseConfig {

    @Value("${spring.flyway.locations:classpath:db/migration}")
    private List<String> flywayLocations;

    @Bean(initMethod = "migrate")
    public Flyway flyway(DataSource dataSource) {
        return Flyway.configure()
                .dataSource(dataSource)
                .locations(flywayLocations.toArray(String[]::new))
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
