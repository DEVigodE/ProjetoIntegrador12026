# CLAUDE.md - Delivery Backoffice Backend

## Visao Geral

Backoffice para sistema de Delivery de Alimentos. Monolito Modular com DDD (Domain-Driven Design).
Projeto academico do Projeto Integrador 2026 cobrindo 4 disciplinas: Desenvolvimento Web, Modelagem de Interfaces, Design de Software e Mensageria/Streams.

- **Grupo**: br.com.logdash
- **Artefato**: logdash-backend
- **Classe principal**: `Startup.java`

## Stack

| Tecnologia | Versao | Uso |
|---|---|---|
| Java | 21 | Linguagem principal |
| Spring Boot | 4.0.3 | Framework web |
| PostgreSQL | 15 | Banco de dados (unico banco, multiplos schemas) |
| Keycloak | 26.5 | Autenticacao OAuth2/OpenID Connect |
| Flyway | - | Migrations de banco |
| Lombok | - | Boilerplate reduction |
| MapStruct | 1.5.5 | Mapeamento DTO <-> Entity |
| SpringDoc OpenAPI | 2.8.6 | Documentacao Swagger |
| WebSocket + STOMP | - | Chat em tempo real |
| Spring Events | - | Comunicacao assincrona entre contextos |

## Como Rodar

```bash
# 1. Subir infra (PostgreSQL + Keycloak)
docker-compose up -d

# 2. Configurar Keycloak automaticamente (PowerShell)
.\setup-keycloak.ps1

# 3. Rodar a aplicacao (perfil dev habilita Flyway e logs DEBUG)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# 4. Testes
./mvnw test
```

- **App**: http://localhost:8081
- **Swagger UI**: http://localhost:8081/swagger-ui.html
- **Keycloak Admin**: http://localhost:8080 (admin/admin)
- **PostgreSQL**: localhost:5432 (delivery_user/delivery_pass, banco delivery_db)

### Usuarios de Teste (criados pelo setup-keycloak.ps1)

| Usuario | Senha | Role |
|---|---|---|
| admin.user | admin123 | ADMIN |
| operator.user | operator123 | OPERATOR |
| dispatcher.user | dispatcher123 | DISPATCHER |

## Arquitetura

### Monolito Modular com DDD

Pacote raiz: `br.com.logdash.backend`

Cada bounded context segue a estrutura de camadas:

```
<contexto>/
  domain/
    model/          # Aggregates, Entities (extends AbstractAggregateRoot)
    valueobject/    # Value Objects (enums, embeddables)
    event/          # Domain Events (extends DomainEvent)
    service/        # Domain Services (logica cross-aggregate)
    repository/     # Interfaces de repositorio (contrato do dominio)
  application/
    dto/            # Request/Response DTOs
    service/        # Application Services (@Transactional, orquestra use cases)
  infrastructure/
    persistence/    # JPA Repositories (implementacoes), *JpaRepository (Spring Data)
    listener/       # Event Listeners (@EventListener, @TransactionalEventListener)
    config/         # Configuracoes especificas do contexto
  presentation/
    controller/     # REST Controllers (@RestController)
    websocket/      # WebSocket Controllers (@MessageMapping) - apenas Communication
```

### 5 Bounded Contexts

| Contexto | Schema | Descricao |
|---|---|---|
| **catalog** | catalog_schema | Produtos, categorias, estoque |
| **orders** | orders_schema | Pedidos, itens, ciclo de vida |
| **delivery** | delivery_schema | Entregadores, entregas |
| **communication** | communication_schema | Chat em tempo real (WebSocket/STOMP) |
| **reporting** | - (cross-schema queries) | Relatorios e dashboard (somente leitura) |

### Modulo Shared

```
shared/
  domain/
    DomainEvent.java       # Classe base para eventos de dominio
    ValueObject.java       # Classe base para value objects
  application/exception/
    GlobalExceptionHandler.java      # @RestControllerAdvice central
    ResourceNotFoundException.java   # 404
    InvalidStateException.java       # 422
    ErrorResponse.java               # DTO padrao de erro
  infrastructure/
    config/
      SecurityConfig.java    # OAuth2 Resource Server + JWT + roles
      WebSocketConfig.java   # STOMP endpoint /ws, broker /topic, /queue
      DatabaseConfig.java    # Flyway multi-schema
      OpenApiConfig.java     # Swagger + OAuth2 PKCE
    event/
      DomainEventPublisher.java  # Wrapper do ApplicationEventPublisher
```

## Padroes de Codigo Obrigatorios

### Domain Models (Aggregates)

- Estendem `AbstractAggregateRoot<T>` (Spring Data)
- Usam `@NoArgsConstructor(access = AccessLevel.PROTECTED)` + `@Getter` (Lombok)
- Criacao via metodo estatico `create(...)` (factory method)
- Logica de negocio dentro da entidade (Rich Domain Model)
- Publicam eventos via `registerEvent(new XxxEvent(...))`
- Campos de auditoria: `createdAt`, `updatedAt`
- Soft delete com `deletedAt` (quando aplicavel, ex: Product)

```java
// Exemplo padrao:
@Entity @Table(name = "products", schema = "catalog_schema")
@Getter @NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Product extends AbstractAggregateRoot<Product> {
    public static Product create(...) { ... registerEvent(...); return product; }
    public void accept() { /* validacao de estado + transicao */ }
}
```

### Transicoes de Estado (State Machine)

- **Order**: PENDING -> ACCEPTED -> PREPARING -> READY -> OUT_FOR_DELIVERY -> DELIVERED | CANCELLED
- **Delivery**: PENDING -> ASSIGNED -> PICKED_UP -> DELIVERED
- **Courier**: AVAILABLE | BUSY | OFFLINE
- Validacoes de transicao dentro do domain model (throw InvalidStateException se invalida)

### Repositories

- Interface no `domain/repository/` (contrato puro, sem dependencia de framework)
- Implementacao no `infrastructure/persistence/` (delega para JpaRepository do Spring Data)
- JpaRepository separado: `*JpaRepository extends JpaRepository<Entity, Long>`

### Application Services

- `@Service @RequiredArgsConstructor`
- `@Transactional` para escrita, `@Transactional(readOnly = true)` para leitura
- Orquestram domain services, repositories e event publishing
- NAO contem logica de negocio (delegam para domain model/service)

### Controllers

- `@RestController @RequestMapping("/api/...")`
- `@RequiredArgsConstructor`
- Seguranca via `@PreAuthorize("hasRole('ADMIN')")` ou `hasAnyRole('ADMIN', 'OPERATOR')`
- Paginacao com `Pageable` do Spring Data
- `@Valid` nos request DTOs
- Retornam `ResponseEntity<T>` com status codes corretos (201 para create, 204 para delete)

### Eventos de Dominio (Spring Events)

Comunicacao entre bounded contexts eh feita via Spring Events (sincrono, in-process).
NUNCA importar classes de outro bounded context diretamente.

| Evento | Produtor | Consumidor(es) |
|---|---|---|
| OrderCreatedEvent | Orders | Communication (cria chat channel) |
| OrderAcceptedEvent | Orders | Catalog (decrementa estoque) |
| OrderRejectedEvent | Orders | - |
| OrderStatusChangedEvent | Orders | Communication (mensagem de sistema) |
| DeliveryAssignedEvent | Delivery | Communication (adiciona participante) |
| DeliveryCompletedEvent | Delivery | Orders (marca como entregue) |
| ProductCreatedEvent | Catalog | - |
| StockChangedEvent | Catalog | - |
| CourierRegisteredEvent | Delivery | - |
| ChatChannelCreatedEvent | Communication | - |
| MessageSentEvent | Communication | - |

Listeners ficam em `infrastructure/listener/` de cada contexto.

## Banco de Dados

### Schemas e Migrations (Flyway)

Migrations em `src/main/resources/db/migration/`:

| Migration | Schema |
|---|---|
| V1__create_catalog_schema.sql | catalog_schema (categories, products) |
| V2__create_orders_schema.sql | orders_schema (orders, order_items) |
| V3__create_delivery_schema.sql | delivery_schema (couriers, deliveries) |
| V4__create_communication_schema.sql | communication_schema (chat_channels, chat_participants, messages) |

Convenção de nomenclatura: `V{numero}__descricao.sql`

### Flyway

- `application.yaml`: Flyway **desabilitado** (configurado manualmente em `DatabaseConfig.java`)
- `application-dev.yaml`: Flyway **habilitado** + SQL debug logs
- O `DatabaseConfig.java` gerencia a execucao do Flyway garantindo que rode antes do Hibernate

### Docker

- `docker-compose.yml` sobe PostgreSQL 15 + Keycloak 26.5
- `init-db/01-create-keycloak-db.sql` cria banco e usuario separados para o Keycloak
- Volume `postgres-data` persiste dados entre restarts
- Network `delivery-network` conecta containers

## Seguranca

- **Autenticacao**: Keycloak (OAuth2 Resource Server com JWT)
- **Realm**: `logdash`
- **Clients**: `logdash-webapp` (mobile app) e `backoffice-webapp` (Swagger/web)
- **JWT issuer-uri**: `http://localhost:8080/realms/logdash`
- **Roles extraidas de**: claim `realm_access.roles` do JWT, prefixadas com `ROLE_`
- **Sessao**: STATELESS (sem estado no servidor)
- **CSRF**: desabilitado (API stateless)
- **Endpoints publicos**: `/ws/**`, `/actuator/health`, `/swagger-ui/**`, `/v3/api-docs/**`

### Roles e Permissoes

| Role | Acesso |
|---|---|
| ADMIN | Acesso total a todos os endpoints |
| OPERATOR | Pedidos, produtos, dashboard |
| DISPATCHER | Entregas e entregadores |

## API REST

Base path: `/api`

### Catalog
- `GET /api/products` - Listar (paginado, filtro por categoria/nome)
- `GET /api/products/{id}` - Buscar por ID
- `POST /api/products` - Criar (ADMIN/OPERATOR)
- `PUT /api/products/{id}` - Atualizar (ADMIN/OPERATOR)
- `DELETE /api/products/{id}` - Soft delete (ADMIN)
- `PATCH /api/products/{id}/availability` - Toggle disponibilidade
- `GET /api/categories` - Listar categorias
- `POST /api/categories` - Criar categoria (ADMIN)

### Orders
- `GET /api/orders` - Listar (paginado)
- `GET /api/orders/{id}` - Buscar por ID
- `POST /api/orders` - Criar pedido
- `GET /api/orders/active` - Pedidos ativos
- `PATCH /api/orders/{id}/accept` - Aceitar
- `PATCH /api/orders/{id}/reject` - Recusar (com motivo)
- `PATCH /api/orders/{id}/status` - Atualizar status

### Delivery
- `GET /api/couriers` - Listar entregadores
- `POST /api/couriers` - Cadastrar (ADMIN/DISPATCHER)
- `PUT /api/couriers/{id}` - Atualizar
- `GET /api/couriers/available` - Disponiveis
- `POST /api/deliveries` - Criar entrega
- `PATCH /api/deliveries/{id}/assign` - Atribuir entregador
- `GET /api/deliveries/active` - Entregas ativas

### Communication
- `GET /api/chat/{orderId}/messages` - Historico
- `GET /api/chat/{orderId}` - Dados do canal

### Reporting
- `GET /api/reports/sales?startDate=&endDate=` - Vendas (ADMIN)
- `GET /api/reports/products/top-selling` - Mais vendidos (ADMIN/OPERATOR)
- `GET /api/reports/metrics` - Metricas gerais
- `GET /api/reports/dashboard` - Dashboard consolidado (ADMIN/OPERATOR)

### WebSocket (STOMP)
- **Endpoint**: `ws://localhost:8081/ws` (com SockJS fallback)
- **Enviar mensagem**: `/app/chat/{orderId}/send`
- **Receber mensagens**: subscribe em `/topic/chat/{orderId}`

## Tratamento de Erros

Centralizado no `GlobalExceptionHandler`:

| Exception | HTTP Status | Codigo |
|---|---|---|
| ResourceNotFoundException | 404 | NOT_FOUND |
| InvalidStateException | 422 | INVALID_STATE |
| MethodArgumentNotValidException | 400 | VALIDATION_ERROR |
| IllegalArgumentException | 400 | BAD_REQUEST |
| AccessDeniedException | 403 | FORBIDDEN |
| Exception (generico) | 500 | INTERNAL_ERROR |

Response padrao: `{ "code": "...", "message": "..." }` (ErrorResponse DTO)

## Testes

- Testes unitarios de dominio em `src/test/java/` seguindo padrao `*Test.java`
- Testes existentes: `ProductTest`, `OrderTest`, `CourierTest`, `OrderApplicationServiceTest`
- Dependencias de teste: spring-boot-starter-test, spring-boot-starter-webmvc-test, spring-boot-starter-data-jpa-test, spring-security-test
- Meta de cobertura: 70%+

## Regras de Negocio Importantes

- Pedido so pode ser aceito se todos os produtos estiverem disponiveis
- Janela de 5 minutos para rejeicao de pedido
- Produtos com estoque zero sao automaticamente desativados
- Estoque eh decrementado automaticamente ao aceitar pedido
- Nao ha mudancas retroativas de status (state machine estrita)
- Somente pedidos "READY" podem ser atribuidos a entregadores
- Um entregador so pode ter uma entrega ativa por vez (simplificacao academica)
- Chat eh arquivado 30 dias apos finalizacao do pedido

## Documentacao do Projeto

Documentacao completa em `../docs/`:

| Arquivo | Conteudo |
|---|---|
| 01-visao-do-projeto.md | Escopo, stakeholders, capacidades |
| 02-requisitos.md | Requisitos funcionais (RF), nao-funcionais (RNF) e regras de negocio (RN) |
| 03-arquitetura.md | Decisoes arquiteturais, DDD, camadas, padroes |
| 04-modelagem-banco-dados.md | Schemas, tabelas, relacionamentos, estrategias de dados |
| 05-diagramas.md | Diagramas de componentes, sequencia, deploy, casos de uso, C4 |
| 06-chat-tempo-real.md | Implementacao WebSocket/STOMP, fluxo de mensagens |
| 07-planejamento-sprints.md | 7 sprints de 2 semanas, cerimonias ageis |
| 08-justificativa-academica.md | Cobertura das 4 disciplinas, padroes de design, SOLID |
| 09-integracao-keycloak.md | Setup Keycloak, fluxos OAuth2, integracao frontend/backend |
| ESTRUTURA-PASTAS.md | Estrutura de diretorios do projeto completo |
| GLOSSARIO.md | Termos tecnicos e de negocio |
| PROMPT-AGENTE-BACKEND.md | Instrucoes para agente IA construir o backend |

## Restricoes e Regras para Desenvolvimento

1. **Monolito Modular** - NAO criar microservicos. Tudo em um unico deployable
2. **DDD obrigatorio** - Rich Domain Models, Aggregates, Value Objects, Domain Events
3. **Spring Events** - Para comunicacao entre contextos. NAO usar chamadas diretas entre contextos
4. **Sem Kafka/RabbitMQ** - Usar apenas Spring Events (ApplicationEventPublisher)
5. **PostgreSQL unico** - Um banco, multiplos schemas. NAO criar bancos separados
6. **Flyway** - Toda mudanca de schema via migration. NUNCA alterar banco manualmente
7. **Keycloak** - Toda autenticacao delegada. NAO implementar login custom
8. **Lombok + MapStruct** - Usar para reduzir boilerplate. Annotation processors configurados no pom.xml
9. **WebSocket + STOMP** - Para chat. Persistencia em PostgreSQL (JPA), NAO MongoDB
10. **SOLID** - Seguir principios SOLID. Classes pequenas, responsabilidade unica
