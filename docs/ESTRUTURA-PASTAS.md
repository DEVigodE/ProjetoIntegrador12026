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
├── backend/                                 # ☕ Backend (Microsserviços)
│   │
│   ├── eureka-server/                       # Service Discovery
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── config-server/                       # Configuração Centralizada
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── api-gateway/                         # API Gateway
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── product-service/                     # Serviço de Produtos
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── order-service/                       # Serviço de Pedidos
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── delivery-service/                    # Serviço de Entregas
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── chat-service/                        # Serviço de Chat
│   │   ├── src/
│   │   └── pom.xml
│   │
│   ├── report-service/                      # Serviço de Relatórios
│   │   ├── src/
│   │   └── pom.xml
│   │
│   └── shared/                              # Código compartilhado
│       ├── common-dto/
│       ├── common-exceptions/
│       └── common-utils/
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
│   ├── docker/                              # Dockerfiles
│   │   ├─── Dockerfile.product
│   │   ├─── Dockerfile.order
│   │   ├── Dockerfile.order
│   │   ├── Dockerfile.delivery
│   │   ├── Dockerfile.chat
│   │   ├── Dockerfile.report
│   │   └── Dockerfile.frontend
│   │
│   ├── docker-compose.yml                   # Compose para dev local
│   │
│   ├── k8s/                                 # Kubernetes manifests
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── secrets.yaml
│   │   │
│   │   ├── databases/
│   │   │   ├── postgres-statefulset.yaml
│   │   │   ├── mongodb-statefulset.yaml
│   │   │   └── redis-deployment.yaml
│   │   │
│   │   ├── kafka/
│   │   │   ├── zookeeper-deployment.yaml
│   │   │   └── kafka-statefulset.yaml
│   │   │
│   │   ├── services/
│   │   │   ├─── keycloak-deployment.yaml
│   │   │   ├── product-deployment.yaml
│   │   │   ├── order-deployment.yaml
│   │   │   ├── delivery-deployment.yaml
│   │   │   ├── chat-deployment.yaml
│   │   │   └── report-deployment.yaml
│   │   │
│   │   ├── ingress.yaml
│   │   └── hpa.yaml
│   │
│   ├── monitoring/                          # Monitoramento
│   │   ├── prometheus/
│   │   │   ├── prometheus-config.yaml
│   │   │   └── prometheus-deployment.yaml
│   │   │
│   │   ├── grafana/
│   │   │   ├── grafana-deployment.yaml
│   │   │   └── dashboards/
│   │   │
│   │   └── elk/
│   │       ├── elasticsearch-deployment.yaml
│   │       ├── logstash-deployment.yaml
│   │       └── kibana-deployment.yaml
│   │
│   └── terraform/                           # Infraestrutura como código
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/                                 # 🔧 Scripts utilitários
│   ├── build-all.sh                         # Build de todos os serviços
│   ├── build-and-push.sh                    # Build e push de imagens
│   ├── deploy-local.sh                      # Deploy local
│   ├── deploy-prod.sh                       # Deploy produção
│   ├── init-db.sh                           # Inicialização de DBs
│   └── cleanup.sh                           # Limpeza de recursos
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

### Backend (Java)

- **Packages**: `com.delivery.<service>.<layer>`
  - Exemplo: `com.delivery.order.controller`
- **Classes**:
  - Controllers: `*Controller.java` (ex: `OrderController.java`)
  - Services: `*Service.java` (ex: `OrderService.java`)
  - Repositories: `*Repository.java` (ex: `OrderRepository.java`)
  - Models: `*.java` (ex: `Order.java`)
  - DTOs: `*DTO.java` (ex: `OrderDTO.java`)
  - Configs: `*Config.java` (ex: `SecurityConfig.java`)

### Frontend (React)

- **Componentes**: PascalCase (ex: `OrderCard.jsx`)
- **Arquivos utilitários**: camelCase (ex: `helpers.js`)
- **Constantes**: UPPER_SNAKE_CASE (ex: `API_BASE_URL`)
- **Hooks**: `use*` (ex: `useAuth.js`)

### Kubernetes

- **Manifests**: kebab-case (ex: `order-deployment.yaml`)
- **Namespaces**: kebab-case (ex: `delivery-system`)
- **Services**: `<serviço>-service` (ex: `order-service`)

### Bancos de Dados

- **Tabelas**: snake_case plural (ex: `orders`, `order_items`)
- **Colunas**: snake_case (ex: `order_id`, `created_at`)
- **Índices**: `idx_<tabela>_<coluna>` (ex: `idx_orders_status`)

---

**Atualizado em**: Fevereiro de 2026
