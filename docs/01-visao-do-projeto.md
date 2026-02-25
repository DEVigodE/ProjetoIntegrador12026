# 📄 Documento de Visão do Projeto

## 1. Introdução

### 1.1 Propósito

Este documento apresenta a visão geral do projeto **Backoffice para Sistema de Delivery de Alimentos**, definindo seus objetivos, escopo, stakeholders e expectativas. O sistema visa fornecer uma plataforma administrativa completa para restaurantes e estabelecimentos de food service gerenciarem suas operações de delivery de forma eficiente e integrada.

### 1.2 Escopo

O projeto abrange o desenvolvimento de uma aplicação web administrativa (backoffice) que permitirá aos estabelecimentos gerenciar:

- Catálogo de produtos
- Pedidos recebidos
- Entregas e entregadores
- Comunicação em tempo real com clientes e entregadores
- Relatórios gerenciais e indicadores de desempenho

### 1.3 Definições, Acrônimos e Abreviações

- **Backoffice**: Sistema administrativo de retaguarda
- **Delivery**: Serviço de entrega de alimentos
- **DDD**: Domain-Driven Design - Abordagem de design de software orientado ao domínio
- **Bounded Context**: Limite explícito dentro do qual um modelo de domínio é definido
- **Aggregate**: Padrão DDD que agrupa entidades relacionadas
- **WebSocket**: Protocolo de comunicação bidirecional em tempo real
- **Event-Driven**: Arquitetura baseada em eventos
- **Keycloak**: Sistema de Identity and Access Management (IAM)
- **STOMP**: Simple Text Oriented Messaging Protocol
- **REST**: Representational State Transfer
- **API**: Application Programming Interface

### 1.4 Referências

- Spring Boot Documentation
- React Documentation
- Domain-Driven Design (Eric Evans)
- Implementing Domain-Driven Design (Vaughn Vernon)
- Design Patterns (Gang of Four)
- Clean Architecture (Robert C. Martin)

---

## 2. Posicionamento

### 2.1 Oportunidade de Negócio

O mercado de delivery de alimentos cresceu exponencialmente nos últimos anos. Estabelecimentos necessitam de ferramentas eficientes para gerenciar operações complexas que envolvem:

- Alto volume de pedidos simultâneos
- Coordenação de múltiplos entregadores
- Comunicação em tempo real com clientes
- Controle preciso de estoque
- Análise de desempenho operacional

### 2.2 Descrição do Problema

| **Item**                | **Descrição**                                                                                     |
|-------------------------|---------------------------------------------------------------------------------------------------|
| **O problema de**       | Gestão ineficiente e manual de operações de delivery                                             |
| **Afeta**               | Restaurantes, lanchonetes e estabelecimentos de food service                                     |
| **Cujo impacto é**      | Perda de pedidos, atrasos, insatisfação do cliente, erros operacionais, falta de controle        |
| **Uma solução bem-sucedida seria** | Um sistema integrado que automatize e centralize todas as operações de delivery     |

### 2.3 Descrição da Posição do Produto

| **Item**           | **Descrição**                                                                                          |
|--------------------|--------------------------------------------------------------------------------------------------------|
| **Para**           | Estabelecimentos de food service que operam com delivery                                              |
| **Quem**           | Precisa gerenciar operações de delivery de forma eficiente e profissional                             |
| **O sistema**      | É uma plataforma web administrativa (backoffice)                                                       |
| **Que**            | Centraliza gestão de produtos, pedidos, entregas e comunicação em tempo real                          |
| **Diferentemente** | De planilhas, WhatsApp ou sistemas fragmentados                                                       |
| **Nosso produto**  | Oferece integração completa, automação de processos e comunicação em tempo real com todas as partes   |

---

## 3. Descrição dos Stakeholders e Usuários

### 3.1 Resumo dos Stakeholders

| **Nome**                  | **Descrição**                                    | **Responsabilidades**                                      |
|---------------------------|--------------------------------------------------|-----------------------------------------------------------|
| Proprietários do Restaurante | Donos e gestores do estabelecimento         | Definir processos, avaliar métricas, tomar decisões       |
| Gerentes/Atendentes       | Operadores do sistema                            | Gerenciar pedidos, produtos, atualizar status             |
| Entregadores              | Profissionais responsáveis pela entrega          | Receber pedidos, atualizar localização, comunicar         |
| Clientes                  | Consumidores finais (usuários indiretos)         | Fazer pedidos, acompanhar status, comunicar               |
| Equipe de Desenvolvimento | Desenvolvedores e arquitetos                     | Construir, testar e manter o sistema                      |

### 3.2 Resumo dos Usuários

| **Nome**           | **Descrição**                                    | **Stakeholder Representado**  |
|--------------------|--------------------------------------------------|------------------------------|
| Administrador      | Acesso completo ao sistema                       | Proprietário                 |
| Operador           | Gerencia pedidos e produtos                      | Gerente/Atendente            |
| Despachante        | Atribui entregas e monitora entregadores         | Gerente                      |

### 3.3 Ambiente do Usuário

- **Quantidade de usuários**: 5-20 usuários simultâneos por estabelecimento
- **Dispositivos**: Desktops, tablets e notebooks
- **Navegadores**: Chrome, Firefox, Edge, Safari (versões recentes)
- **Conexão**: Internet banda larga (recomendado mínimo 5 Mbps)
- **Horário de uso**: Principalmente 10h-23h, com picos no almoço e jantar

---

## 4. Visão Geral do Produto

### 4.1 Perspectiva do Produto

O sistema será desenvolvido como uma aplicação web moderna, baseada em **arquitetura monolítica modular com Domain-Driven Design (DDD)**, com frontend em React e backend em Spring Boot. A solução será:

- **Modular**: Organizada em Bounded Contexts bem definidos (Catalog, Orders, Delivery, Chat, Reporting)
- **Manutenível**: Separação clara entre camadas (Application, Domain, Infrastructure)
- **Escalável**: Capacidade de crescer verticalmente e, futuramente, evoluir para microsserviços se necessário
- **Responsiva**: Interface adaptável a diferentes tamanhos de tela
- **Tempo real**: Comunicação instantânea via WebSocket e eventos de domínio

### 4.2 Resumo das Capacidades

| **Benefício para o Cliente**                   | **Recursos de Suporte**                                    |
|------------------------------------------------|------------------------------------------------------------|
| Gerenciamento centralizado de produtos         | CRUD completo, controle de disponibilidade e estoque       |
| Controle eficiente de pedidos                  | Recebimento, aceite/recusa, atualização de status          |
| Coordenação de entregas                        | Atribuição automática/manual, rastreamento                 |
| Comunicação integrada                          | Chat em tempo real no contexto do pedido                   |
| Visão gerencial do negócio                     | Reports, dashboards, indicadores de performance            |
| Redução de erros operacionais                  | Automação de processos, validações de negócio             |

### 4.3 Suposições e Dependências

- Os estabelecimentos possuem infraestrutura básica de internet
- Usuários têm conhecimento básico de uso de sistemas web
- O sistema dependerá de serviços externos para:
  - Autenticação e autorização (Keycloak - OAuth 2.0 / OpenID Connect)
  - Armazenamento de arquivos (S3 ou similar)
  - Mapas e geolocalização (Google Maps API)
- Integração futura com aplicativos de cliente (mobile/web) via APIs

---

## 5. Recursos do Produto

### 5.1 Gestão de Produtos

Permite cadastrar, editar e remover produtos do catálogo, além de controlar disponibilidade, preços, descrições, imagens e estoque.

### 5.2 Gestão de Pedidos

Recebe pedidos em tempo real, permite aceitar ou recusar, e acompanhar toda a jornada do pedido através de status bem definidos.

### 5.3 Gestão de Entregas

Controla entregadores cadastrados, atribui pedidos e monitora o progresso das entregas.

### 5.4 Chat Integrado (Tempo Real)

Fornece canal de comunicação instantânea entre loja, cliente e entregador, no contexto de cada pedido.

### 5.5 Relatórios e Analytics

Gera relatórios de vendas, estoque e operacionais, além de indicadores como ticket médio, volume de pedidos e performance.

---

## 6. Restrições

### 6.1 Restrições de Design

- Interface deve seguir princípios de Material Design ou Ant Design
- Responsividade obrigatória para tablets (mínimo)
- Acessibilidade conforme WCAG 2.1 nível AA

### 6.2 Restrições de Implementação

- Backend obrigatoriamente em Java + Spring Boot
- Frontend obrigatoriamente em React
- Arquitetura baseada em Domain-Driven Design (DDD)
- Organização em Bounded Contexts
- Uso de containers Docker para deploy

### 6.3 Restrições de Segurança

- Autenticação via Keycloak (OAuth 2.0 / OpenID Connect) obrigatória
- Tokens JWT para autorização
- Comunicação HTTPS obrigatória em produção
- Proteção contra CSRF, XSS e SQL Injection
- Logs de auditoria para operações críticas

### 6.4 Restrições Acadêmicas

O projeto deve demonstrar aplicação prática de conceitos de:

- Desenvolvimento Web
- Modelagem de Interfaces de Usuário
- Design de Software
- Mensageria e Streams

---

## 7. Faixas de Qualidade

### 7.1 Desempenho

- Tempo de resposta das APIs: < 500ms (95th percentile)
- Latência do chat: < 100ms
- Suporte a 100 pedidos simultâneos por instância
- Tempo de startup da aplicação: < 30 segundos

### 7.2 Disponibilidade

- Uptime: 99% (objetivo acadêmico)
- Recuperação de falhas: < 5 minutos

### 7.3 Usabilidade

- Interface intuitiva, curva de aprendizado < 2 horas
- Feedbacks visuais claros para todas as ações

### 7.4 Manutenibilidade

- Cobertura de testes: mínimo 70%
- Documentação de APIs (Swagger/OpenAPI)
- Código seguindo padrões de clean code

---

## 8. Precedência e Prioridade

| **Recurso**               | **Prioridade** | **Esforço** | **Risco**  |
|---------------------------|----------------|-------------|------------|
| Gestão de Produtos        | Alta           | Médio       | Baixo      |
| Gestão de Pedidos         | Crítica        | Alto        | Médio      |
| Gestão de Entregas        | Alta           | Médio       | Médio      |
| Chat Tempo Real           | Crítica        | Alto        | Alto       |
| Relatórios                | Média          | Médio       | Baixo      |

---

## 9. Outros Requisitos do Produto

### 9.1 Requisitos Legais

- Conformidade com LGPD (Lei Geral de Proteção de Dados)
- Termos de uso e política de privacidade

### 9.2 Requisitos de Documentação

- Manual do usuário
- Documentação técnica (APIs, arquitetura)
- Guia de implantação

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
