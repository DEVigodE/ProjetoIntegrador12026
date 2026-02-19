# 🍔 Backoffice de Sistema de Delivery

![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow)
![License](https://img.shields.io/badge/License-MIT-blue)
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-brightgreen)
![React](https://img.shields.io/badge/React-18-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue)

## 📖 Sobre o Projeto

Sistema de backoffice (área administrativa) para gestão de operações de delivery de alimentos. Desenvolvido como projeto integrador acadêmico, aplicando conceitos de:

- **Desenvolvimento Web** (Full-stack)
- **Modelagem de Interfaces de Usuário** (UI/UX)
- **Design de Software** (Arquitetura, Padrões)
- **Mensageria e Streams** (Tempo Real, Eventos)

### 🎯 Funcionalidades Principais

- ✅ **Gestão de Produtos**: CRUD completo, controle de estoque, categorias
- ✅ **Gestão de Pedidos**: Recebimento, aceite/recusa, atualização de status em tempo real
- ✅ **Gestão de Entregas**: Cadastro de entregadores, atribuição de pedidos
- ✅ **Chat Integrado**: Comunicação em tempo real (Loja ↔ Cliente ↔ Entregador)
- ✅ **Relatórios Gerenciais**: Vendas, estoque, métricas operacionais

---

## 🏗️ Arquitetura

### Visão Geral

```
┌─────────────┐
│   React     │  Frontend (SPA)
│  Frontend   │
└──────┬──────┘
       │ HTTPS / WSS
┌──────▼─────────────────────────────────┐
│        API Gateway                     │  Roteamento, Auth
│     (Spring Cloud Gateway)             │
└──────┬─────────────────────────────────┘
       │
┌──────┴──────────────────────────────────┐
│         Microsserviços                   │
│                                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ Product │  │  Order  │  │Delivery│ │
│  │ Service │  │ Service │  │ Service │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│                                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │ Chat    │  │ Report  │  │Keycloak│ │
│  │ Service │  │ Service │  │  (IAM)  │ │
│  └─────────┘  └─────────┘  └─────────┘ │
└──────────────────────────────────────────┘
       │                    │
┌──────▼──────┐      ┌──────▼──────┐
│   Kafka     │      │  Databases  │
│  (Events)   │      │ (PostgreSQL,│
└─────────────┘      │  MongoDB)   │
                     └─────────────┘
```

### Stack Tecnológica

#### Backend
- **Framework**: Spring Boot 3.x
- **Cloud**: Spring Cloud (Eureka, Gateway, Config Server)
- **Autenticação**: Keycloak (OAuth 2.0 / OpenID Connect)
- **Segurança**: Spring Security
- **Banco de Dados**: PostgreSQL, MongoDB
- **Cache**: Redis
- **Mensageria**: Apache Kafka, Redis Pub/Sub
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
- **Orquestração**: Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoramento**: Prometheus + Grafana
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)

---

## 📚 Documentação

Toda a documentação está organizada na pasta [`docs/`](./docs/):

| Documento | Descrição |
|-----------|-----------|
| [01 - Visão do Projeto](./docs/01-visao-do-projeto.md) | Objetivos, stakeholders, escopo |
| [02 - Requisitos](./docs/02-requisitos.md) | Requisitos funcionais e não funcionais |
| [03 - Arquitetura](./docs/03-arquitetura.md) | Arquitetura de microsserviços, tecnologias |
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
# Subir PostgreSQL, MongoDB, Redis, Kafka, Zookeeper, Keycloak
docker-compose up -d
```

### 3. Configurar Keycloak

Acessar Admin Console: http://localhost:8080
- Usuário: `admin`
- Senha: `admin`

Seguir instruções de configuração em: [Integração com Keycloak](./docs/09-integracao-keycloak.md)

```bash
# Eureka Server
cd eureka-server
mvn spring-boot:run

# Config Server
cd config-server
mvn spring-boot:run

# API Gateway
cd api-gateway
mvn spring-boot:run
```

### 4. Executar Serviços de Infraestrutura

```bash
# Eureka Server
cd eureka-server
mvn spring-boot:run

# Config Server
cd config-server
mvn spring-boot:run

# API Gateway
cd api-gateway
mvn spring-boot:run
```

### 5. Executar Microsserviços

Em terminais separados:

```bash
# Product Service
cd product-service
mvn spring-boot:run

# Order Service
cd order-service
mvn spring-boot:run

# Delivery Service
cd delivery-service
mvn spring-boot:run

# Chat Service
cd chat-service
mvn spring-boot:run

# Report Service
cd report-service
mvn spring-boot:run
```

### 6. Executar Frontend

```bash
cd frontend
npm install
npm run dev
```

### 7. Acessar Aplicação

- **Frontend**: http://localhost:5173
- **Keycloak**: http://localhost:8080
- **API Gateway**: http://localhost:8081
- **Eureka Dashboard**: http://localhost:8761
- **Swagger UI**: http://localhost:8081/swagger-ui.html

---

## 🧪 Testes

### Testes Unitários

```bash
# Todos os serviços
mvn test

# Serviço específico
cd order-service
mvn test
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

### Deploy Local (Kubernetes com Minikube)

```bash
# Iniciar Minikube
minikube start

# Build de imagens
./build-images.sh

# Deploy
kubectl apply -f k8s/

# Verificar pods
kubectl get pods

# Acessar aplicação
minikube service api-gateway-service
```

### Deploy em Cluster (GKE, EKS, AKS)

```bash
# Build e push de imagens
./build-and-push.sh

# Deploy
kubectl apply -f k8s/production/
```

---

## 📊 Monitoramento

### Prometheus

```bash
# Acessar Prometheus
kubectl port-forward svc/prometheus 9090:9090
# Abrir http://localhost:9090
```

### Grafana

```bash
# Acessar Grafana
kubectl port-forward svc/grafana 3000:3000
# Abrir http://localhost:3000
# Credenciais: admin / admin
```

### Logs (Kibana)

```bash
# Acessar Kibana
kubectl port-forward svc/kibana 5601:5601
# Abrir http://localhost:5601
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
