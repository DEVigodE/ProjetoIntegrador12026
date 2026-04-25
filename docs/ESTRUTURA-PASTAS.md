# Estrutura de Pastas do Projeto

Este documento descreve a organização de pastas e arquivos do projeto.

```
ProjetoIntegrador12026/
│
├── docs/                                    # 📚 Documentação
│   ├── README.md                            # Índice da documentação
│   ├── 01-visao-do-projeto.md
│   ├── 02-requisitos.md
│   ├── 03-arquitetura.md
│   ├── 04-modelagem-banco-dados.md
│   ├── 05-diagramas.md
│   ├── 06-chat-tempo-real.md
│   ├── 07-planejamento-sprints.md
│   └── 08-justificativa-academica.md
│
├── backend/                                 # ☕ Backend (Monólito DDD)
│   │
│   └── logdash/                 # Aplicação Monolítica
│       ├── src/
│       │   ├── main/
│       │   │   ├── java/
│       │   │   │   └── com/
│       │   │   │       └── delivery/
│       │   │   │           └── backoffice/
│       │   │   │               │
│       │   │   │               ├── Application.java           # Main class
│       │   │   │               │
│       │   │   │               ├── shared/                    # Código compartilhado
│       │   │   │               │   ├── domain/
│       │   │   │               │   │   ├── DomainEvent.java
│       │   │   │               │   │   └── ValueObject.java
│       │   │   │               │   ├── infrastructure/
│       │   │   │               │   │   ├── config/
│       │   │   │               │   │   │   ├── SecurityConfig.java
│       │   │   │               │   │   │   ├── WebSocketConfig.java
│       │   │   │               │   │   │   └── DatabaseConfig.java
│       │   │   │               │   │   └── event/
│       │   │   │               │   │       └── DomainEventPublisher.java
│       │   │   │               │   └── application/
│       │   │   │               │       └── exception/
│       │   │   │               │           └── GlobalExceptionHandler.java
│       │   │   │               │
│       │   │   │               ├── catalog/                   # Bounded Context: Catálogo
│       │   │   │               │   ├── domain/                # Domain Layer
│       │   │   │               │   │   ├── model/
│       │   │   │               │   │   │   ├── Product.java
│       │   │   │               │   │   │   ├── Category.java
│       │   │   │               │   │   │   └── Stock.java
│       │   │   │               │   │   ├── valueobject/
│       │   │   │               │   │   │   ├── Money.java
│       │   │   │               │   │   │   ├── ProductStatus.java
│       │   │   │               │   │   │   └── ProductImage.java
│       │   │   │               │   │   ├── event/
│       │   │   │               │   │   │   ├── ProductCreatedEvent.java
│       │   │   │               │   │   │   └── StockChangedEvent.java
│       │   │   │               │   │   ├── repository/
│       │   │   │               │   │   │   ├── ProductRepository.java
│       │   │   │               │   │   │   └── CategoryRepository.java
│       │   │   │               │   │   └── service/
│       │   │   │               │   │       └── ProductDomainService.java
│       │   │   │               │   │
│       │   │   │               │   ├── application/           # Application Layer
│       │   │   │               │   │   ├── service/
│       │   │   │               │   │   │   └── ProductApplicationService.java
│       │   │   │               │   │   └── dto/
│       │   │   │               │   │       ├── ProductRequest.java
│       │   │   │               │   │       └── ProductResponse.java
│       │   │   │               │   │
│       │   │   │               │   ├── infrastructure/        # Infrastructure Layer
│       │   │   │               │   │   ├── persistence/
│       │   │   │               │   │   │   ├── ProductJpaRepository.java
│       │   │   │               │   │   │   └── ProductRepositoryImpl.java
│       │   │   │               │   │   └── listener/
│       │   │   │               │   │       └── CatalogEventListener.java
│       │   │   │               │   │
│       │   │   │               │   └── presentation/          # Presentation Layer
│       │   │   │               │       └── controller/
│       │   │   │               │           └── ProductController.java
│       │   │   │               │
│       │   │   │               ├── orders/                    # Bounded Context: Pedidos
│       │   │   │               │   ├── domain/
│       │   │   │               │   │   ├── model/
│       │   │   │               │   │   │   ├── Order.java
│       │   │   │               │   │   │   └── OrderItem.java
│       │   │   │               │   │   ├── valueobject/
│       │   │   │               │   │   │   ├── OrderStatus.java
│       │   │   │               │   │   │   ├── CustomerInfo.java
│       │   │   │               │   │   │   └── Address.java
│       │   │   │               │   │   ├── event/
│       │   │   │               │   │   ├── repository/
│       │   │   │               │   │   └── service/
│       │   │   │               │   ├── application/
│       │   │   │               │   ├── infrastructure/
│       │   │   │               │   └── presentation/
│       │   │   │               │
│       │   │   │               ├── delivery/                  # Bounded Context: Entregas
│       │   │   │               │   ├── domain/
│       │   │   │               │   ├── application/
│       │   │   │               │   ├── infrastructure/
│       │   │   │               │   └── presentation/
│       │   │   │               │
│       │   │   │               ├── communication/             # Bounded Context: Comunicação
│       │   │   │               │   ├── domain/
│       │   │   │               │   ├── application/
│       │   │   │               │   ├── infrastructure/
│       │   │   │               │   └── presentation/
│       │   │   │               │
│       │   │   │               └── reporting/                 # Bounded Context: Relatórios
│       │   │   │                   ├── domain/
│       │   │   │                   ├── application/
│       │   │   │                   ├── infrastructure/
│       │   │   │                   └── presentation/
│       │   │   │
│       │   │   └── resources/
│       │   │       ├── application.yml
│       │   │       ├── application-dev.yml
│       │   │       ├── application-prod.yml
│       │   │       ├── db/
│       │   │       │   └── migration/                 # Flyway migrations
│       │   │       │       ├── V1__create_catalog_schema.sql
│       │   │       │       ├── V2__create_orders_schema.sql
│       │   │       │       └── V3__create_delivery_schema.sql
│       │   │       └── static/
│       │   │
│       │   └── test/                                  # Testes
│       │       ├── java/
│       │       │   └── com/
│       │       │       └── delivery/
│       │       │           └── backoffice/
│       │       │               ├── catalog/
│       │       │               │   ├── domain/
│       │       │               │   └── application/
│       │       │               ├── orders/
│       │       │               └── delivery/
│       │       │
│       │       └── resources/
│       │           └── application-test.yml
│       │
│       ├── pom.xml
│       ├── Dockerfile
│       └── README.md
│
├── frontend/                                # ⚛️ Frontend (React)
│   ├── public/
│   │   ├── index.html
│   │   └── favicon.ico
│   │
│   ├── src/
│   │   ├── assets/                          # Imagens, fontes
│   │   ├── components/                      # Componentes reutilizáveis
│   │   │   ├── common/
│   │   │   │   ├── Button/
│   │   │   │   ├── Card/
│   │   │   │   ├── Modal/
│   │   │   │   └── Table/
│   │   │   ├── layout/
│   │   │   │   ├── Header/
│   │   │   │   ├── Sidebar/
│   │   │   │   └── Footer/
│   │   │   └── features/
│   │   │       ├── orders/
│   │   │       ├── products/
│   │   │       ├── chat/
│   │   │       └── reports/
│   │   │
│   │   ├── pages/                           # Páginas da aplicação
│   │   │   ├── Login/
│   │   │   ├── Dashboard/
│   │   │   ├── Orders/
│   │   │   ├── Products/
│   │   │   ├── Deliveries/
│   │   │   └── Reports/
│   │   │
│   │   ├── services/                        # Serviços de API
│   │   │   ├── api.js
│   │   │   ├── keycloak.js                  # Configuração Keycloak
│   │   │   ├── orderService.js
│   │   │   ├── productService.js
│   │   │   ├── chatService.js
│   │   │   └── websocketService.js
│   │   │
│   │   ├── store/                           # Estado global (Redux/Zustand)
│   │   │   ├── slices/
│   │   │   │   ├── authSlice.js
│   │   │   │   ├── orderSlice.js
│   │   │   │   └── productSlice.js
│   │   │   └── store.js
│   │   │
│   │   ├── hooks/                           # Custom Hooks
│   │   │   ├── useAuth.js
│   │   │   ├── useWebSocket.js
│   │   │   └── useOrders.js
│   │   │
│   │   ├── utils/                           # Utilitários
│   │   │   ├── constants.js
│   │   │   ├── helpers.js
│   │   │   └── validators.js
│   │   │
│   │   ├── styles/                          # Estilos globais
│   │   │   ├── theme.js
│   │   │   ├── global.css
│   │   │   └── variables.css
│   │   │
│   │   ├── App.jsx
│   │   └── main.jsx
│   │
│   ├── package.json
│   ├── vite.config.js
│   └── .eslintrc.js
│
├── infra/                                   # 🐳 Infraestrutura
│   │
│   ├── docker/
│   │   ├── Dockerfile.backend               # Backend monolito
│   │   └── Dockerfile.frontend              # Frontend
│   │
│   └── docker-compose.yml                   # Compose para dev local
│
├── scripts/                                 # 🔧 Scripts utilitários
│   ├── build.sh                             # Build da aplicação
│   ├── deploy-local.sh                      # Deploy local
│   └── init-db.sh                           # Inicialização de DBs
│
├── tests/                                   # 🧪 Testes E2E
│   ├── e2e/
│   │   ├── auth.spec.js
│   │   ├── orders.spec.js
│   │   └── chat.spec.js
│   │
│   └── load/
│       ├── load-test.jmx
│       └── stress-test.jmx
│
├── .github/                                 # ⚙️ CI/CD
│   └── workflows/
│       ├── backend-ci.yml
│       ├── frontend-ci.yml
│       ├── deploy-staging.yml
│       └── deploy-production.yml
│
├── .gitignore
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

## Convenções de Nomenclatura

### Backend (Java) - DDD

- **Packages por Bounded Context**: `com.delivery.backoffice.<context>.<layer>`
  - Exemplo: `com.delivery.backoffice.catalog.domain.model`
  - Exemplo: `com.delivery.backoffice.orders.application.service`

- **Camadas DDD**:
  - **Domain Layer**: Aggregates, Entities, Value Objects, Domain Services, Events
  - **Application Layer**: Application Services, DTOs, Use Cases
  - **Infrastructure Layer**: Repositories (impl), Configs, External APIs
  - **Presentation Layer**: Controllers, Request/Response DTOs

- **Classes**:
  - Aggregates/Entities: Substantivos (ex: `Order.java`, `Product.java`)
  - Value Objects: Substantivos (ex: `Money.java`, `OrderStatus.java`)
  - Domain Events: `*Event.java` (ex: `OrderCreatedEvent.java`)
  - Application Services: `*ApplicationService.java` (ex: `OrderApplicationService.java`)
  - Domain Services: `*DomainService.java` (ex: `PricingDomainService.java`)
  - Repositories (interface): `*Repository.java` (ex: `OrderRepository.java`)
  - Repositories (impl): `*RepositoryImpl.java` (ex: `OrderRepositoryImpl.java`)
  - Controllers: `*Controller.java` (ex: `OrderController.java`)
  - DTOs: `*Request.java` / `*Response.java` (ex: `CreateOrderRequest.java`)

### Frontend (React)

- **Componentes**: PascalCase (ex: `OrderCard.jsx`)
- **Arquivos utilitários**: camelCase (ex: `helpers.js`)
- **Constantes**: UPPER_SNAKE_CASE (ex: `API_BASE_URL`)
- **Hooks**: `use*` (ex: `useAuth.js`)

### Bancos de Dados

- **Schemas**: Um por bounded context (ex: `catalog`, `orders`, `delivery`)
- **Tabelas**: snake_case plural (ex: `orders`, `order_items`)
- **Colunas**: snake_case (ex: `order_id`, `created_at`)
- **Índices**: `idx_<tabela>_<coluna>` (ex: `idx_orders_status`)

---

**Atualizado em**: Fevereiro de 2026
