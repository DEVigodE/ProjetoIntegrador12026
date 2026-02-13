# 📖 Glossário de Termos Técnicos

Guia de referência para termos e conceitos utilizados no projeto de Backoffice de Sistema de Delivery.

---

## A

**ACID**: Propriedades de transações em bancos de dados: Atomicidade, Consistência, Isolamento e Durabilidade.

**API (Application Programming Interface)**: Interface que permite comunicação entre sistemas de software.

**API Gateway**: Serviço que atua como ponto único de entrada para um conjunto de APIs, realizando roteamento, autenticação e agregação.

**Assíncrono**: Operação que não bloqueia a execução, permitindo que outras tarefas sejam executadas enquanto aguarda resposta.

**Autoscaling**: Capacidade de ajustar automaticamente a quantidade de recursos (servidores, containers) baseado na demanda.

---

## B

**Backoffice**: Sistema administrativo de retaguarda, usado internamente por funcionários de uma empresa.

**Broker**: Intermediário que gerencia troca de mensagens entre produtores e consumidores (ex: Kafka).

**Business Logic**: Regras de negócio que definem como dados são criados, manipulados e armazenados.

---

## C

**Cache**: Armazenamento temporário de dados frequentemente acessados para melhorar performance.

**Circuit Breaker**: Padrão de design que impede que falhas em cascata ocorram em sistemas distribuídos.

**Clean Code**: Práticas de escrita de código legível, manutenível e eficiente.

**Client-Server**: Arquitetura onde clientes fazem requisições e servidores processam e respondem.

**Cloud Native**: Aplicações projetadas para rodar em ambientes de computação em nuvem.

**Containerização**: Empacotamento de aplicações com suas dependências em containers isolados (ex: Docker).

**CORS (Cross-Origin Resource Sharing)**: Mecanismo que permite requisições de um domínio diferente da origem.

**CRUD**: Create, Read, Update, Delete - operações básicas em dados.

**CQRS (Command Query Responsibility Segregation)**: Padrão que separa operações de leitura e escrita.

---

## D

**DTO (Data Transfer Object)**: Objeto usado para transferir dados entre camadas da aplicação.

**Database per Service**: Padrão onde cada microsserviço possui seu próprio banco de dados.

**Deployment**: Processo de disponibilizar uma aplicação em um ambiente (dev, staging, prod).

**DevOps**: Cultura que integra desenvolvimento e operações para entregar software mais rapidamente.

**Docker**: Plataforma para criação e execução de containers.

**Domain Model**: Representação de conceitos de negócio em código.

---

## E

**EDA (Event-Driven Architecture)**: Arquitetura baseada em eventos onde serviços se comunicam através de mensagens.

**Endpoint**: URL específica de uma API que realiza uma operação.

**Event Sourcing**: Padrão onde mudanças de estado são armazenadas como sequência de eventos.

**Event**: Notificação de que algo aconteceu no sistema.

---

## F

**Fallback**: Estratégia alternativa executada quando operação principal falha.

**Feign Client**: Biblioteca para criar clients HTTP declarativos no Spring.

**Frontend**: Parte da aplicação que roda no navegador e interage com usuário.

---

## G

**Gateway**: Ver API Gateway.

**Gradle/Maven**: Ferramentas de build e gerenciamento de dependências para Java.

---

## H

**HPA (Horizontal Pod Autoscaler)**: Recurso do Kubernetes que escala pods automaticamente.

**Health Check**: Verificação periódica se um serviço está funcionando corretamente.

**HTTPS**: Protocolo HTTP com camada de segurança (TLS/SSL).

---

## I

**Idempotência**: Propriedade onde executar a mesma operação múltiplas vezes produz o mesmo resultado.

**Ingress**: Recurso do Kubernetes que gerencia acesso externo aos serviços.

**IoC (Inversion of Control)**: Princípio onde framework controla fluxo da aplicação.

---

## J

**JPA (Java Persistence API)**: API para mapeamento objeto-relacional em Java.

**JSON (JavaScript Object Notation)**: Formato leve de troca de dados.

**JWT (JSON Web Token)**: Padrão para tokens de autenticação.

---

## K

**Kafka**: Plataforma de streaming de eventos distribuída.

**Kubernetes (K8s)**: Sistema de orquestração de containers.

---

## L

**Latência**: Tempo de atraso entre requisição e resposta.

**Load Balancer**: Distribui tráfego entre múltiplas instâncias de um serviço.

**Logs**: Registros de eventos e operações no sistema.

---

## M

**Message Broker**: Ver Broker.

**Microservices (Microsserviços)**: Arquitetura onde aplicação é dividida em serviços pequenos e independentes.

**Middleware**: Software que conecta diferentes sistemas ou componentes.

**MongoDB**: Banco de dados NoSQL orientado a documentos.

**MVC (Model-View-Controller)**: Padrão arquitetural que separa dados, lógica e apresentação.

---

## N

**NoSQL**: Bancos de dados não relacionais (MongoDB, Redis, Cassandra).

---

## O

**ORM (Object-Relational Mapping)**: Técnica de mapeamento entre objetos e tabelas relacionais.

**Orchestration**: Coordenação automatizada de sistemas complexos (ex: Kubernetes).

---

## P

**Partition**: Divisão de dados em Kafka para paralelização.

**Payload**: Dados transportados em requisição ou mensagem.

**Pod**: Menor unidade de deploy no Kubernetes, contém um ou mais containers.

**PostgreSQL**: Banco de dados relacional open-source.

**Producer**: Serviço que publica mensagens em um broker.

**Prometheus**: Sistema de monitoramento e alerta.

**Pub/Sub (Publish/Subscribe)**: Padrão onde produtores publicam mensagens e consumidores se inscrevem em tópicos.

---

## R

**Rate Limiting**: Limitação de número de requisições em um período de tempo.

**Redis**: Banco de dados em memória usado para cache e pub/sub.

**Replica**: Cópia de dados ou serviço para redundância e escalabilidade.

**Repository Pattern**: Padrão que abstrai acesso a dados.

**REST (Representational State Transfer)**: Estilo arquitetural para APIs web.

**Retry**: Tentativa automática de reexecutar operação que falhou.

---

## S

**Saga Pattern**: Padrão para gerenciar transações distribuídas através de eventos.

**Scalability (Escalabilidade)**: Capacidade de sistema aumentar capacidade conforme demanda.

**Service Discovery**: Mecanismo para localizar instâncias de serviços dinamicamente.

**Service Layer**: Camada que contém lógica de negócio.

**Soft Delete**: Marcar registro como excluído sem removê-lo fisicamente do banco.

**SOLID**: Princípios de design orientado a objetos (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion).

**SPA (Single Page Application)**: Aplicação web que carrega uma única página HTML e atualiza conteúdo dinamicamente.

**Spring Boot**: Framework Java para criar aplicações stand-alone.

**Spring Cloud**: Framework para construir sistemas distribuídos.

**Spring Security**: Framework de segurança para aplicações Java.

**State Machine**: Modelo computacional com estados e transições definidas.

**Stateless**: Serviço que não armazena estado de sessão entre requisições.

**STOMP (Simple Text Oriented Messaging Protocol)**: Protocolo de mensageria sobre WebSocket.

**Stream**: Fluxo contínuo de dados processados em tempo real.

---

## T

**Throughput**: Quantidade de operações processadas por unidade de tempo.

**TLS/SSL**: Protocolos de segurança para comunicação criptografada.

**Topic**: Canal de comunicação em Kafka para categorizar mensagens.

**Transaction**: Conjunto de operações que devem ser executadas completamente ou não serem executadas.

---

## U

**UI (User Interface)**: Interface do usuário.

**UX (User Experience)**: Experiência do usuário ao interagir com sistema.

**UUID (Universally Unique Identifier)**: Identificador único universal.

---

## V

**Virtual DOM**: Representação em memória do DOM usado pelo React para otimizar atualizações.

---

## W

**WCAG (Web Content Accessibility Guidelines)**: Diretrizes de acessibilidade web.

**WebSocket**: Protocolo de comunicação bidirecional em tempo real.

---

## Termos de Negócio

**Backoffice**: Sistema administrativo da loja.

**Customer (Cliente)**: Pessoa que faz pedidos.

**Delivery (Entrega)**: Processo de levar pedido ao cliente.

**Delivery Person (Entregador)**: Profissional que realiza entregas.

**Order (Pedido)**: Solicitação de produtos pelo cliente.

**Product (Produto)**: Item vendido pela loja.

**Stock (Estoque)**: Quantidade disponível de produtos.

**Status**: Estado atual do pedido (Recebido, Aceito, Em Preparo, etc).

---

## Status de Pedido

| **Status** | **Descrição** |
|------------|---------------|
| `RECEIVED` | Pedido recebido, aguardando aceite da loja |
| `ACCEPTED` | Pedido aceito pela loja |
| `IN_PREPARATION` | Pedido sendo preparado |
| `READY` | Pedido pronto para entrega |
| `OUT_FOR_DELIVERY` | Pedido saiu para entrega |
| `DELIVERED` | Pedido entregue ao cliente |
| `CANCELED` | Pedido cancelado |
| `REJECTED` | Pedido recusado pela loja |

---

## Códigos HTTP Comuns

| **Código** | **Nome** | **Significado** |
|------------|----------|-----------------|
| 200 | OK | Requisição bem-sucedida |
| 201 | Created | Recurso criado com sucesso |
| 204 | No Content | Sucesso, sem corpo de resposta |
| 400 | Bad Request | Requisição inválida |
| 401 | Unauthorized | Não autenticado |
| 403 | Forbidden | Não autorizado (sem permissão) |
| 404 | Not Found | Recurso não encontrado |
| 409 | Conflict | Conflito (ex: recurso duplicado) |
| 500 | Internal Server Error | Erro no servidor |
| 503 | Service Unavailable | Serviço temporariamente indisponível |

---

## Verbos HTTP

| **Verbo** | **Uso** | **Idempotente** | **Exemplo** |
|-----------|---------|-----------------|-------------|
| GET | Buscar dados | Sim | GET /orders |
| POST | Criar recurso | Não | POST /orders |
| PUT | Atualizar recurso completo | Sim | PUT /orders/123 |
| PATCH | Atualizar parcialmente | Não* | PATCH /orders/123/status |
| DELETE | Remover recurso | Sim | DELETE /orders/123 |

\* PATCH pode ser idempotente dependendo da implementação

---

## Siglas de Testes

**TDD**: Test-Driven Development (Desenvolvimento Guiado por Testes)

**BDD**: Behavior-Driven Development (Desenvolvimento Guiado por Comportamento)

**E2E**: End-to-End (Testes de ponta a ponta)

**UAT**: User Acceptance Testing (Teste de Aceitação do Usuário)

---

## Recursos Úteis

### Documentação Oficial

- [Spring Boot](https://spring.io/projects/spring-boot)
- [React](https://react.dev/)
- [Kafka](https://kafka.apache.org/)
- [Kubernetes](https://kubernetes.io/)
- [Docker](https://docs.docker.com/)

### Artigos e Tutoriais

- [Microservices.io](https://microservices.io/)
- [Martin Fowler's Blog](https://martinfowler.com/)
- [12 Factor App](https://12factor.net/)

---

**Última atualização**: Fevereiro de 2026

**Contribuições**: Se você identificou algum termo faltante ou incorreção, por favor abra um issue ou pull request!
