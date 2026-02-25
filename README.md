# 🍔 Backoffice de Sistema de Delivery

![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow)
![License](https://img.shields.io/badge/License-MIT-blue)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen)
![React](https://img.shields.io/badge/React-18-blue)
![DDD](https://img.shields.io/badge/Architecture-DDD-purple)

## 📖 Sobre o Projeto

Sistema de backoffice (área administrativa) para gestão de operações de delivery de alimentos. Desenvolvido como projeto integrador acadêmico utilizando **Domain-Driven Design (DDD)** com arquitetura monolítica modular, aplicando conceitos de:

- **Desenvolvimento Web** (Full-stack)
- **Modelagem de Interfaces de Usuário** (UI/UX)
- **Design de Software** (DDD, Clean Architecture, Padrões)
- **Mensageria e Streams** (Tempo Real, Eventos de Domínio)

### 🎯 Funcionalidades Principais

- ✅ **Gestão de Produtos**: CRUD completo, controle de estoque, categorias
- ✅ **Gestão de Pedidos**: Recebimento, aceite/recusa, atualização de status em tempo real
- ✅ **Gestão de Entregas**: Cadastro de entregadores, atribuição de pedidos
- ✅ **Chat Integrado**: Comunicação em tempo real (Loja ↔ Cliente ↔ Entregador)
- ✅ **Relatórios Gerenciais**: Vendas, estoque, métricas operacionais

---

## 🏗️ Arquitetura

### Visão Geral - Domain-Driven Design (DDD)

```
┌─────────────┐
│   React     │  Frontend (SPA)
│  Frontend   │
└──────┬──────┘
       │ HTTPS / WSS
       │
┌──────▼──────────────────────────────────────────────────────┐
│              MONOLITO MODULAR (DDD)                         │
│                                                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │           Application Layer (Controllers)          │     │
│  │  • REST Controllers  • WebSocket Handlers          │     │
│  │  • Security Filters  • Exception Handlers          │     │
│  └─────────────┬──────────────────────────────────────┘     │
│                │                                            │
│  ┌─────────────▼──────────────────────────────────────┐     │
│  │         Application Services (Use Cases)           │     │
│  │  • OrderApplicationService                         │     │
│  │  • ProductApplicationService                       │     │
│  │  • DeliveryApplicationService                      │     │
│  └─────────────┬──────────────────────────────────────┘     │
│                │                                            │
│  ┌─────────────▼──────────────────────────────────────┐     │
│  │              BOUNDED CONTEXTS (Domain)             │     │
│  │                                                    │     │
│  │  ┌──────────┐  ┌──────────┐  ┌───────────┐         │     │
│  │  │ Catalog  │  │  Orders  │  │ Delivery  │         │     │
│  │  │ Context  │  │ Context  │  │  Context  │         │     │
│  │  ├──────────┤  ├──────────┤  ├───────────┤         │     │
│  │  │Aggregates│  │Aggregates│  │ Aggregates│         │     │
│  │  │ Product  │  │  Order   │  │ Delivery  │         │     │
│  │  │ Category │  │  Item    │  │ Courier   │         │     │
│  │  ├──────────┤  ├──────────┤  ├───────────┤         │     │
│  │  │ Entities │  │ Entities │  │  Entities │         │     │
│  │  │  & VOs   │  │  & VOs   │  │   & VOs   │         │     │
│  │  ├──────────┤  ├──────────┤  ├───────────┤         │     │
│  │  │  Domain  │  │  Domain  │  │  Domain   │         │     │
│  │  │ Services │  │ Services │  │  Services │         │     │
│  │  ├──────────┤  ├──────────┤  ├───────────┤         │     │
│  │  │  Events  │  │  Events  │  │  Events   │         │     │
│  │  └──────────┘  └──────────┘  └───────────┘         │     │
│  │                                                    │     │
│  │  ┌──────────┐  ┌──────────┐                        │     │
│  │  │   Chat   │  │  Report  │                        │     │
│  │  │ Context  │  │ Context  │                        │     │
│  │  └──────────┘  └──────────┘                        │     │
│  └─────────────┬──────────────────────────────────────┘     │
│                │                                            │
│  ┌─────────────▼──────────────────────────────────────┐     │
│  │         Infrastructure Layer                       │     │
│  │  • Repositories (JPA)  • Messaging (Events)        │     │
│  │  • External APIs       • File Storage              │     │
│  │  • Security (Keycloak) • WebSocket (STOMP)         │     │
│  └────────────────────────────────────────────────────┘     │
└──────────────────┬──────────────────────────────────────────┘
                   │
    ┌──────────────┼──────────────┐
    │              │              │
┌───▼────┐  ┌──────▼───────┐  ┌──▼──────┐
│  DB    │  │   Events     │  │Keycloak │
│Postgres│  │ (Internal    │  │  (IAM)  │
│  +     │  │  EventBus)   │  └─────────┘
│MongoDB │  └──────────────┘
└────────┘
```

### Stack Tecnológica

#### Backend
- **Arquitetura**: Domain-Driven Design (DDD) - Monolito Modular
- **Framework**: Spring Boot 3.x
- **Design Pattern**: Clean Architecture com Bounded Contexts
- **Autenticação**: Keycloak (OAuth 2.0 / OpenID Connect)
- **Segurança**: Spring Security
- **Banco de Dados**: PostgreSQL (principal), MongoDB (chat)
- **Cache**: Redis
- **Mensageria**: Event Bus interno (Spring Events) + Redis Pub/Sub
- **Tempo Real**: WebSocket + STOMP
- **Documentação**: OpenAPI (Swagger)

#### Frontend
- **Framework**: React 18+
- **Linguagem**: JavaScript/TypeScript
- **UI Library**: Material-UI ou Ant Design
- **Estado**: Redux ou Zustand
- **HTTP Client**: Axios
- **WebSocket**: SockJS + STOMP.js

#### DevOps
- **Containers**: Docker
- **Deployment**: Docker Compose (dev), Docker Swarm ou Kubernetes (prod)
- **CI/CD**: GitHub Actions
- **Monitoramento**: Spring Boot Actuator + Prometheus + Grafana
- **Logs**: Logback + ELK Stack (opcional)

---

## 📚 Documentação

Toda a documentação está organizada na pasta [`docs/`](./docs/):

| Documento | Descrição |
|-----------|-----------|
| [01 - Visão do Projeto](./docs/01-visao-do-projeto.md) | Objetivos, stakeholders, escopo |
| [02 - Requisitos](./docs/02-requisitos.md) | Requisitos funcionais e não funcionais |
| [03 - Arquitetura](./docs/03-arquitetura.md) | Arquitetura DDD monolítica modular, bounded contexts |
| [04 - Modelagem de BD](./docs/04-modelagem-banco-dados.md) | Modelos de dados, scripts SQL |
| [05 - Diagramas](./docs/05-diagramas.md) | Diagramas UML (componentes, sequência, classes) |
| [06 - Chat Tempo Real](./docs/06-chat-tempo-real.md) | Implementação do chat em tempo real |
| [07 - Planejamento Sprints](./docs/07-planejamento-sprints.md) | Cronograma e user stories |
| [08 - Justificativa Acadêmica](./docs/08-justificativa-academica.md) | Alinhamento com disciplinas |
| [09 - Integração Keycloak](./docs/09-integracao-keycloak.md) | OAuth 2.0, OpenID Connect, configuração |

---

## 🚀 Como Executar

### Pré-requisitos

- **Java**: JDK 17+
- **Node.js**: v18+
- **Docker**: v20+
- **Docker Compose**: v2+
- **Maven**: v3.8+
- **Git**: v2.30+

### 1. Clonar o Repositório

```bash
git clone https://github.com/DEVigodE/ProjetoIntegrador12026.git
cd ProjetoIntegrador12026
```

### 2. Subir Infraestrutura (Docker Compose)

```bash
# Subir PostgreSQL, MongoDB, Redis, Keycloak
docker-compose up -d
```

### 3. Configurar Keycloak

Acessar Admin Console: http://localhost:8080
- Usuário: `admin`
- Senha: `admin`

Seguir instruções de configuração em: [Integração com Keycloak](./docs/09-integracao-keycloak.md)

### 4. Executar Aplicação Backend (Monolito)

```bash
cd backend/delivery-backoffice
mvn spring-boot:run
```

Ou com perfil específico:

```bash
# Desenvolvimento
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Produção
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

### 5. Executar Frontend

```bash
cd frontend
npm install
npm run dev
```

### 6. Acessar Aplicação

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Actuator**: http://localhost:8080/actuator
- **Keycloak**: http://localhost:8180

---

## 🧪 Testes

### Testes Unitários

```bash
# Todos os testes
cd backend/delivery-backoffice
mvn test

# Testes de um contexto específico
mvn test -Dtest=com.delivery.catalog.*
```

### Testes de Integração

```bash
mvn verify
```

### Cobertura de Código

```bash
mvn clean test jacoco:report
# Relatório em target/site/jacoco/index.html
```

### Testes E2E (Frontend)

```bash
cd frontend
npm run test:e2e
```

---

## 📦 Deploy

### Build da Aplicação

```bash
# Build JAR
cd backend/delivery-backoffice
mvn clean package -DskipTests

# Build Docker Image
docker build -t delivery-backoffice:latest .
```

### Deploy com Docker Compose

```bash
# Deploy completo (backend + frontend + infraestrutura)
docker-compose -f docker-compose.prod.yml up -d
```

### Deploy Kubernetes (Opcional)

```bash
# Build e push da imagem
docker build -t seu-registry/delivery-backoffice:latest .
docker push seu-registry/delivery-backoffice:latest

# Deploy
kubectl apply -f k8s/

# Verificar status
kubectl get pods -n delivery
```

---

## 📊 Monitoramento

### Spring Boot Actuator

```bash
# Endpoints de monitoramento
curl http://localhost:8080/actuator/health
curl http://localhost:8080/actuator/metrics
curl http://localhost:8080/actuator/info
```

### Prometheus (Opcional)

```bash
# Métricas disponíveis em
http://localhost:8080/actuator/prometheus
```

### Logs

```bash
# Ver logs da aplicação
docker logs -f delivery-backoffice

# Logs em arquivo
tail -f logs/application.log
```

---

## 🤝 Contribuindo

### Fluxo de Trabalho

1. Criar branch a partir de `main`: `git checkout -b feature/nome-da-feature`
2. Fazer commits: `git commit -m "feat: adiciona funcionalidade X"`
3. Push: `git push origin feature/nome-da-feature`
4. Abrir Pull Request no GitHub
5. Aguardar code review
6. Merge após aprovação

### Padrão de Commits (Conventional Commits)

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Formatação (sem mudança de código)
- `refactor:` Refatoração
- `test:` Adição/modificação de testes
- `chore:` Tarefas gerais (build, CI)

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.

---

## 👥 Equipe

- **[Nome 1]** - Backend Developer - [GitHub](https://github.com/usuario1)
- **[Nome 2]** - Frontend Developer - [GitHub](https://github.com/usuario2)
- **[Nome 3]** - DevOps Engineer - [GitHub](https://github.com/usuario3)
- **[Nome 4]** - Full-stack Developer - [GitHub](https://github.com/usuario4)

---

## 📞 Contato

- **Instituição**: [Nome da Instituição]
- **Curso**: Engenharia de Software / Ciência da Computação
- **Período**: 2026.1
- **Professor Orientador**: [Nome do Professor]

---

## 🙏 Agradecimentos

- Professores das disciplinas envolvidas
- Colegas de turma pelo apoio
- Comunidade open source pelas ferramentas incríveis

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela!**

---

## 📸 Screenshots (TODO)

### Dashboard de Pedidos
![Dashboard](./docs/images/dashboard.png)

### Chat em Tempo Real
![Chat](./docs/images/chat.png)

### Gestão de Produtos
![Produtos](./docs/images/products.png)

---

## 🔗 Links Úteis

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [React Documentation](https://react.dev/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Material-UI](https://mui.com/)

---

**Última atualização**: Fevereiro de 2026
