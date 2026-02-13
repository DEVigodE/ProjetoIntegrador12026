# 📅 Planejamento de Sprints

## 1. Introdução

Este documento apresenta o planejamento detalhado do projeto dividido em sprints de 2 semanas, totalizando 14 semanas de desenvolvimento (7 sprints), adequado para um semestre acadêmico.

---

## 2. Cronograma Geral

| **Sprint** | **Período** | **Duração** | **Tema Principal** |
|------------|-------------|-------------|--------------------|
| Sprint 0   | Sem 1-2     | 2 semanas   | Setup e Fundação   |
| Sprint 1   | Sem 3-4     | 2 semanas   | Infraestrutura e Auth |
| Sprint 2   | Sem 5-6     | 2 semanas   | Gestão de Produtos |
| Sprint 3   | Sem 7-8     | 2 semanas   | Gestão de Pedidos  |
| Sprint 4   | Sem 9-10    | 2 semanas   | Chat em Tempo Real |
| Sprint 5   | Sem 11-12   | 2 semanas   | Entregas e Relatórios |
| Sprint 6   | Sem 13-14   | 2 semanas   | Refinamento e Deploy |

---

## 3. Sprint 0 - Setup e Fundação (Semanas 1-2)

### 3.1 Objetivos
- Configurar ambiente de desenvolvimento
- Definir estrutura de repositórios
- Criar documentação inicial
- Setup de infraestrutura básica

### 3.2 User Stories

**US-001: Como desenvolvedor, quero configurar o ambiente de desenvolvimento**
- **Tarefas**:
  - [ ] Instalar JDK 17, Node.js, Docker Desktop
  - [ ] Instalar IDEs (IntelliJ IDEA, VS Code)
  - [ ] Configurar Git e criar repositórios
  - [ ] Configurar Docker Compose para ambiente local
- **Estimativa**: 8h
- **DoD**: Todos os membros conseguem rodar containers localmente

**US-002: Como arquiteto, quero criar a estrutura base dos microsserviços**
- **Tarefas**:
  - [ ] Criar projeto Eureka Server
  - [ ] Criar projeto Config Server
  - [ ] Criar projeto API Gateway
  - [ ] Configurar discovery e routing básico
- **Estimativa**: 16h
- **DoD**: Serviços se registram no Eureka e Gateway roteia requisições

**US-003: Como desenvolvedor, quero documentar a arquitetura do sistema**
- **Tarefas**:
  - [ ] Documento de Visão
  - [ ] Requisitos Funcionais e Não Funcionais
  - [ ] Diagrama de Arquitetura
  - [ ] Modelagem de Banco de Dados
- **Estimativa**: 12h
- **DoD**: Documentação revisada e aprovada

### 3.3 Entregáveis
- Ambiente de desenvolvimento configurado
- Infraestrutura base (Eureka, Config, Gateway)
- Documentação inicial completa
- Docker Compose funcional

### 3.4 Critérios de Aceite
- Todos os membros conseguem subir a infraestrutura localmente
- Documentação publicada no repositório
- Health check de todos os serviços passando

---

## 4. Sprint 1 - Infraestrutura e Autenticação (Semanas 3-4)

### 4.1 Objetivos
- Implementar serviço de autenticação
- Configurar bancos de dados
- Setup de Kafka
- Iniciar frontend React

### 4.2 User Stories

**US-004: Como administrador, quero fazer login no sistema**
- **Tarefas**:
  - [ ] Criar Auth Service (Spring Boot)
  - [ ] Implementar JWT generation/validation
  - [ ] Criar endpoints de login/logout
  - [ ] Configurar PostgreSQL para Auth
  - [ ] Criar tabelas de users, roles, refresh_tokens
- **Estimativa**: 20h
- **DoD**: Login funcional retornando JWT válido

**US-005: Como desenvolvedor, quero proteger rotas com autenticação**
- **Tarefas**:
  - [ ] Implementar filtro JWT no Gateway
  - [ ] Configurar Spring Security
  - [ ] Implementar refresh token
  - [ ] Adicionar tratamento de erros de autenticação
- **Estimativa**: 12h
- **DoD**: Rotas protegidas retornam 401 sem token válido

**US-006: Como usuário, quero acessar interface de login**
- **Tarefas**:
  - [ ] Criar projeto React com Vite
  - [ ] Configurar estrutura de pastas
  - [ ] Implementar tela de login
  - [ ] Integrar com Auth API
  - [ ] Implementar fluxo de autenticação (JWT storage)
- **Estimativa**: 16h
- **DoD**: Login funcional no frontend com redirecionamento

**US-007: Como desenvolvedor, quero configurar Kafka para eventos**
- **Tarefas**:
  - [ ] Setup Kafka cluster com Docker
  - [ ] Criar tópicos básicos
  - [ ] Implementar producer/consumer exemplo
  - [ ] Configurar serialização JSON
- **Estimativa**: 12h
- **DoD**: Evento de teste publicado e consumido com sucesso

### 4.3 Entregáveis
- Auth Service completo
- Frontend React com login funcional
- Kafka configurado e operacional
- Filtro de autenticação no Gateway

### 4.4 Definição de Pronto (DoD)
- Código revisado (Code Review)
- Testes unitários com cobertura > 70%
- Documentação de APIs (Swagger)
- Build passando no CI/CD

---

## 5. Sprint 2 - Gestão de Produtos (Semanas 5-6)

### 5.1 Objetivos
- Implementar CRUD de produtos
- Controle de estoque
- Interface de gestão de produtos

### 5.2 User Stories

**US-008: Como operador, quero cadastrar produtos**
- **Tarefas**:
  - [ ] Criar Product Service
  - [ ] Implementar endpoints CRUD de produtos
  - [ ] Criar modelo de dados (Product, Category)
  - [ ] Configurar PostgreSQL para Product
  - [ ] Implementar validações de negócio
- **Estimativa**: 16h
- **DoD**: CRUD completo de produtos via API

**US-009: Como operador, quero gerenciar categorias de produtos**
- **Tarefas**:
  - [ ] Implementar CRUD de categorias
  - [ ] Criar relacionamento Product-Category
  - [ ] Adicionar filtros por categoria
- **Estimativa**: 8h
- **DoD**: Produtos podem ser categorizados e filtrados

**US-010: Como operador, quero controlar estoque de produtos**
- **Tarefas**:
  - [ ] Adicionar campo stock_quantity
  - [ ] Implementar endpoint de atualização de estoque
  - [ ] Implementar alerta de estoque baixo
  - [ ] Desativar produto automaticamente se estoque = 0
- **Estimativa**: 12h
- **DoD**: Estoque atualizado corretamente com alertas funcionando

**US-011: Como operador, quero visualizar e gerenciar produtos na interface**
- **Tarefas**:
  - [ ] Criar tela de listagem de produtos
  - [ ] Criar formulário de cadastro/edição
  - [ ] Implementar upload de imagem
  - [ ] Adicionar filtros e busca
  - [ ] Implementar paginação
- **Estimativa**: 20h
- **DoD**: Interface completa para gestão de produtos

**US-012: Como desenvolvedor, quero cachear produtos frequentes**
- **Tarefas**:
  - [ ] Configurar Redis
  - [ ] Implementar cache com Spring Cache
  - [ ] Configurar TTL e invalidação
- **Estimativa**: 8h
- **DoD**: Produtos em cache com tempo de resposta < 50ms

### 5.3 Entregáveis
- Product Service completo
- Interface de gestão de produtos
- Cache Redis implementado
- Documentação de endpoints

---

## 6. Sprint 3 - Gestão de Pedidos (Semanas 7-8)

### 6.1 Objetivos
- Implementar gestão completa de pedidos
- Fluxo de status de pedidos
- Integração com Product Service via eventos

### 6.2 User Stories

**US-013: Como sistema, quero receber pedidos**
- **Tarefas**:
  - [ ] Criar Order Service
  - [ ] Implementar modelo de dados (Order, OrderItem, Customer)
  - [ ] Criar endpoint POST /orders
  - [ ] Configurar PostgreSQL para Order
  - [ ] Publicar evento order.created
- **Estimativa**: 16h
- **DoD**: Pedidos criados e persistidos com evento publicado

**US-014: Como operador, quero visualizar pedidos em tempo real**
- **Tarefas**:
  - [ ] Criar tela de dashboard de pedidos
  - [ ] Implementar WebSocket para notificação de novos pedidos
  - [ ] Adicionar notificação sonora
  - [ ] Implementar auto-refresh da lista
- **Estimativa**: 16h
- **DoD**: Novos pedidos aparecem automaticamente com som

**US-015: Como operador, quero aceitar ou recusar pedidos**
- **Tarefas**:
  - [ ] Implementar endpoint PATCH /orders/{id}/accept
  - [ ] Implementar endpoint PATCH /orders/{id}/reject
  - [ ] Adicionar validação de tempo (5 min)
  - [ ] Publicar eventos order.accepted / order.rejected
- **Estimativa**: 12h
- **DoD**: Pedidos podem ser aceitos/recusados com validações

**US-016: Como operador, quero atualizar status do pedido**
- **Tarefas**:
  - [ ] Implementar máquina de estados (State Pattern)
  - [ ] Criar endpoint PATCH /orders/{id}/status
  - [ ] Registrar histórico de mudanças (OrderStatusHistory)
  - [ ] Publicar evento order.status.changed
- **Estimativa**: 16h
- **DoD**: Status atualizado com histórico e evento publicado

**US-017: Como sistema, quero decrementar estoque ao aceitar pedido**
- **Tarefas**:
  - [ ] Product Service: Consumir evento order.accepted
  - [ ] Implementar lógica de decremento de estoque
  - [ ] Tratar erro de estoque insuficiente
  - [ ] Publicar evento stock.updated
- **Estimativa**: 12h
- **DoD**: Estoque decrementado automaticamente ao aceitar pedido

**US-018: Como operador, quero visualizar detalhes do pedido**
- **Tarefas**:
  - [ ] Criar tela de detalhes do pedido
  - [ ] Exibir informações do cliente e endereço
  - [ ] Exibir itens do pedido
  - [ ] Exibir timeline de status
- **Estimativa**: 12h
- **DoD**: Detalhes completos do pedido visualizáveis

### 6.3 Entregáveis
- Order Service completo com máquina de estados
- Interface de gestão de pedidos
- Integração assíncrona com Product Service
- Notificações em tempo real

---

## 7. Sprint 4 - Chat em Tempo Real (Semanas 9-10)

### 7.1 Objetivos
- Implementar chat em tempo real
- WebSocket + STOMP + Redis Pub/Sub
- Integração com eventos de pedido

### 7.2 User Stories

**US-019: Como sistema, quero criar chat automaticamente ao criar pedido**
- **Tarefas**:
  - [ ] Criar Chat Service
  - [ ] Configurar MongoDB para chat
  - [ ] Consumir evento order.created
  - [ ] Criar documento Chat com participantes
- **Estimativa**: 12h
- **DoD**: Chat criado automaticamente ao criar pedido

**US-020: Como usuário, quero enviar e receber mensagens em tempo real**
- **Tarefas**:
  - [ ] Configurar WebSocket + STOMP
  - [ ] Implementar endpoint /ws/chat
  - [ ] Criar model Message
  - [ ] Persistir mensagens no MongoDB
  - [ ] Implementar tópico /topic/chat/{orderId}
- **Estimativa**: 20h
- **DoD**: Mensagens enviadas e recebidas instantaneamente

**US-021: Como desenvolvedor, quero sincronizar chat entre múltiplas instâncias**
- **Tarefas**:
  - [ ] Configurar Redis Pub/Sub
  - [ ] Implementar publisher ao enviar mensagem
  - [ ] Implementar subscriber para broadcast via WebSocket
  - [ ] Testar com múltiplas instâncias
- **Estimativa**: 16h
- **DoD**: Mensagens sincronizadas entre todas as instâncias

**US-022: Como sistema, quero enviar mensagens automáticas ao mudar status**
- **Tarefas**:
  - [ ] Consumir evento order.status.changed
  - [ ] Gerar mensagem do sistema baseada no status
  - [ ] Salvar e enviar via WebSocket
- **Estimativa**: 8h
- **DoD**: Mensagens automáticas enviadas ao mudar status

**US-023: Como operador, quero visualizar e usar o chat na interface**
- **Tarefas**:
  - [ ] Implementar componente de Chat (React)
  - [ ] Integrar SockJS e STOMP client
  - [ ] Exibir histórico de mensagens
  - [ ] Implementar envio de mensagens
  - [ ] Adicionar indicador de novas mensagens
- **Estimativa**: 20h
- **DoD**: Chat funcional e integrado à interface de pedidos

**US-024: Como sistema, quero adicionar entregador ao chat**
- **Tarefas**:
  - [ ] Consumir evento delivery.assigned
  - [ ] Adicionar entregador aos participantes do chat
  - [ ] Enviar mensagem de boas-vindas
- **Estimativa**: 8h
- **DoD**: Entregador adicionado ao chat ao ser atribuído

### 7.3 Entregáveis
- Chat Service completo com WebSocket
- Redis Pub/Sub configurado
- Interface de chat integrada
- Mensagens automáticas funcionando

---

## 8. Sprint 5 - Entregas e Relatórios (Semanas 11-12)

### 8.1 Objetivos
- Implementar gestão de entregas
- Desenvolver relatórios gerenciais
- Dashboard com métricas

### 8.2 User Stories

**US-025: Como admin, quero cadastrar entregadores**
- **Tarefas**:
  - [ ] Criar Delivery Service
  - [ ] Implementar CRUD de entregadores
  - [ ] Configurar PostgreSQL para Delivery
  - [ ] Criar interface de cadastro
- **Estimativa**: 12h
- **DoD**: Entregadores cadastrados e gerenciados

**US-026: Como despachante, quero atribuir pedidos a entregadores**
- **Tarefas**:
  - [ ] Implementar endpoint POST /deliveries
  - [ ] Listar entregadores disponíveis
  - [ ] Atribuir pedido a entregador
  - [ ] Publicar evento delivery.assigned
  - [ ] Atualizar status do entregador para BUSY
- **Estimativa**: 16h
- **DoD**: Pedidos atribuídos com evento publicado

**US-027: Como despachante, quero visualizar entregas ativas**
- **Tarefas**:
  - [ ] Criar tela de gestão de entregas
  - [ ] Listar entregas em andamento
  - [ ] Exibir status de entregadores
  - [ ] Permitir atribuição de pedidos
- **Estimativa**: 12h
- **DoD**: Interface de gestão de entregas funcional

**US-028: Como admin, quero visualizar relatório de vendas**
- **Tarefas**:
  - [ ] Criar Report Service
  - [ ] Configurar read replica do Order DB
  - [ ] Implementar endpoint GET /reports/sales
  - [ ] Filtrar por período (dia, semana, mês)
  - [ ] Criar tela de relatório de vendas
- **Estimativa**: 16h
- **DoD**: Relatório de vendas por período funcionando

**US-029: Como admin, quero visualizar métricas operacionais**
- **Tarefas**:
  - [ ] Calcular ticket médio
  - [ ] Calcular total de pedidos
  - [ ] Calcular taxa de aceitação
  - [ ] Criar dashboard com cards de métricas
- **Estimativa**: 12h
- **DoD**: Dashboard com métricas em tempo real

**US-030: Como admin, quero visualizar relatório de estoque**
- **Tarefas**:
  - [ ] Implementar endpoint GET /reports/stock
  - [ ] Listar produtos com estoque baixo
  - [ ] Criar tela de relatório de estoque
- **Estimativa**: 8h
- **DoD**: Relatório de estoque funcional

### 8.3 Entregáveis
- Delivery Service completo
- Report Service com relatórios
- Dashboard de métricas
- Interfaces de entregas e relatórios

---

## 9. Sprint 6 - Refinamento e Deploy (Semanas 13-14)

### 9.1 Objetivos
- Testes de integração
- Deploy em Kubernetes
- Monitoramento e observabilidade
- Documentação final

### 9.2 User Stories

**US-031: Como desenvolvedor, quero garantir qualidade com testes**
- **Tarefas**:
  - [ ] Escrever testes de integração
  - [ ] Aumentar cobertura de testes para > 70%
  - [ ] Testes E2E com Cypress/Playwright
  - [ ] Testes de carga com JMeter
- **Estimativa**: 20h
- **DoD**: Cobertura > 70%, testes E2E passando

**US-032: Como DevOps, quero fazer deploy em Kubernetes**
- **Tarefas**:
  - [ ] Criar Dockerfiles para todos os serviços
  - [ ] Criar manifests Kubernetes (Deployment, Service, Ingress)
  - [ ] Configurar ConfigMaps e Secrets
  - [ ] Deploy em cluster local (Minikube/Kind)
  - [ ] Configurar HPA (Horizontal Pod Autoscaler)
- **Estimativa**: 24h
- **DoD**: Todos os serviços rodando em Kubernetes

**US-033: Como DevOps, quero monitorar a aplicação**
- **Tarefas**:
  - [ ] Configurar Prometheus para métricas
  - [ ] Configurar Grafana com dashboards
  - [ ] Configurar ELK Stack para logs
  - [ ] Implementar health checks em todos os serviços
- **Estimativa**: 16h
- **DoD**: Dashboards funcionando com métricas em tempo real

**US-034: Como equipe, quero documentar o projeto completamente**
- **Tarefas**:
  - [ ] Atualizar documentação técnica
  - [ ] Criar manual do usuário
  - [ ] Documentar APIs com OpenAPI
  - [ ] Criar guia de instalação e deploy
  - [ ] Preparar apresentação final
- **Estimativa**: 16h
- **DoD**: Documentação completa e revisada

**US-035: Como equipe, quero refinar a experiência do usuário**
- **Tarefas**:
  - [ ] Melhorar responsividade do frontend
  - [ ] Ajustar UX baseado em feedback
  - [ ] Otimizar performance
  - [ ] Corrigir bugs identificados
- **Estimativa**: 16h
- **DoD**: Interface polida e sem bugs críticos

### 9.3 Entregáveis
- Aplicação completa em Kubernetes
- Monitoramento configurado (Prometheus + Grafana + ELK)
- Documentação final completa
- Apresentação do projeto
- Vídeo de demonstração

---

## 10. Cerimônias Ágeis

### 10.1 Daily Standup
- **Frequência**: Diária (15 minutos)
- **Formato**: Cada membro responde:
  - O que fiz ontem?
  - O que farei hoje?
  - Há algum impedimento?

### 10.2 Sprint Planning
- **Frequência**: Início de cada sprint
- **Duração**: 2 horas
- **Objetivo**: Selecionar e estimar user stories

### 10.3 Sprint Review
- **Frequência**: Final de cada sprint
- **Duração**: 1 hora
- **Objetivo**: Demonstrar funcionalidades desenvolvidas

### 10.4 Sprint Retrospective
- **Frequência**: Final de cada sprint
- **Duração**: 1 hora
- **Objetivo**: Identificar melhorias no processo

---

## 11. Recursos e Papéis

### 11.1 Papéis Sugeridos

| **Papel** | **Responsabilidades** |
|-----------|----------------------|
| **Product Owner** | Priorização do backlog, definição de requisitos |
| **Scrum Master** | Facilitar cerimônias, remover impedimentos |
| **Backend Developer** | Implementar microsserviços (Java/Spring) |
| **Frontend Developer** | Implementar interface (React) |
| **DevOps Engineer** | Infraestrutura, CI/CD, Kubernetes |
| **QA Engineer** | Testes, qualidade, automação |

*Nota: Em equipes pequenas, membros podem acumular papéis*

### 11.2 Ferramentas

- **Gestão de Projeto**: Jira, Trello, GitHub Projects
- **Controle de Versão**: Git + GitHub/GitLab
- **CI/CD**: GitHub Actions, Jenkins
- **Comunicação**: Discord, Slack, Microsoft Teams
- **Documentação**: Notion, Confluence, GitHub Wiki

---

## 12. Critérios de Sucesso do Projeto

- [ ] Todos os requisitos funcionais de alta prioridade implementados
- [ ] Cobertura de testes > 70%
- [ ] Aplicação rodando em Kubernetes
- [ ] Chat em tempo real funcional
- [ ] Documentação completa
- [ ] Deploy automatizado
- [ ] Monitoramento configurado
- [ ] Apresentação final realizada

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
