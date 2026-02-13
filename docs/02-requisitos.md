# 📋 Especificação de Requisitos

## 1. Introdução

Este documento detalha os requisitos funcionais (RF), não funcionais (RNF) e regras de negócio (RN) do sistema de Backoffice para Delivery de Alimentos.

---

## 2. Requisitos Funcionais (RF)

### 2.1 Módulo de Autenticação e Autorização

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF001  | O sistema deve permitir login com email e senha | Alta |
| RF002  | O sistema deve implementar autenticação JWT | Alta |
| RF003  | O sistema deve suportar diferentes perfis de acesso (Admin, Operador, Despachante) | Alta |
| RF004  | O sistema deve permitir recuperação de senha via email | Média |
| RF005  | O sistema deve registrar logs de acesso | Média |

---

### 2.2 Módulo de Gestão de Produtos

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF010  | O sistema deve permitir cadastrar produtos com nome, descrição, preço, categoria e imagem | Alta |
| RF011  | O sistema deve permitir editar informações de produtos | Alta |
| RF012  | O sistema deve permitir excluir produtos (soft delete) | Alta |
| RF013  | O sistema deve permitir ativar/desativar disponibilidade de produtos | Alta |
| RF014  | O sistema deve permitir controlar estoque de produtos | Alta |
| RF015  | O sistema deve alertar quando estoque estiver abaixo do mínimo | Média |
| RF016  | O sistema deve permitir categorizar produtos | Alta |
| RF017  | O sistema deve permitir adicionar variações de produtos (tamanhos, opcionais) | Média |
| RF018  | O sistema deve permitir upload de imagens de produtos | Alta |
| RF019  | O sistema deve listar produtos com filtros e paginação | Alta |

---

### 2.3 Módulo de Gestão de Pedidos

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF020  | O sistema deve receber pedidos em tempo real | Crítica |
| RF021  | O sistema deve notificar visualmente e sonoramente novos pedidos | Crítica |
| RF022  | O sistema deve permitir aceitar pedidos | Crítica |
| RF023  | O sistema deve permitir recusar pedidos com justificativa | Alta |
| RF024  | O sistema deve permitir atualizar status do pedido (Recebido, Em Preparo, Pronto, Saiu para Entrega, Finalizado, Cancelado) | Crítica |
| RF025  | O sistema deve exibir detalhes completos do pedido (produtos, quantidades, cliente, endereço, valor) | Alta |
| RF026  | O sistema deve calcular tempo médio de preparo e exibir estimativa | Média |
| RF027  | O sistema deve listar pedidos com filtros por status, data, cliente | Alta |
| RF028  | O sistema deve permitir visualizar histórico completo do pedido | Alta |
| RF029  | O sistema deve atualizar automaticamente a lista de pedidos em tempo real | Crítica |

---

### 2.4 Módulo de Gestão de Entregas

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF030  | O sistema deve permitir cadastrar entregadores | Alta |
| RF031  | O sistema deve exibir status de entregadores (Disponível, Em Entrega, Offline) | Alta |
| RF032  | O sistema deve permitir atribuir pedido a entregador (manual ou automático) | Alta |
| RF033  | O sistema deve listar entregas em andamento | Alta |
| RF034  | O sistema deve exibir localização do entregador em mapa (integração futura) | Baixa |
| RF035  | O sistema deve registrar histórico de entregas por entregador | Média |
| RF036  | O sistema deve calcular métricas de performance de entregadores | Média |

---

### 2.5 Módulo de Chat em Tempo Real

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF040  | O sistema deve criar automaticamente um chat ao criar o pedido | Crítica |
| RF041  | O sistema deve permitir troca de mensagens entre loja e cliente em tempo real | Crítica |
| RF042  | O sistema deve adicionar o entregador ao chat quando o pedido sair para entrega | Crítica |
| RF043  | O sistema deve exibir indicador de digitação (typing indicator) | Baixa |
| RF044  | O sistema deve exibir status de leitura das mensagens | Baixa |
| RF045  | O sistema deve permitir envio de mensagens rápidas (templates) | Média |
| RF046  | O sistema deve manter histórico de mensagens do pedido | Alta |
| RF047  | O sistema deve notificar visualmente quando há novas mensagens | Alta |
| RF048  | O sistema deve permitir envio de imagens (opcional) | Baixa |

---

### 2.6 Módulo de Relatórios e Analytics

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF050  | O sistema deve gerar relatório de vendas por período (dia, semana, mês) | Alta |
| RF051  | O sistema deve gerar relatório de produtos mais vendidos | Média |
| RF052  | O sistema deve calcular e exibir ticket médio | Alta |
| RF053  | O sistema deve exibir total de pedidos por período | Alta |
| RF054  | O sistema deve exibir taxa de aceitação/recusa de pedidos | Média |
| RF055  | O sistema deve gerar relatório de estoque | Alta |
| RF056  | O sistema deve exibir tempo médio de preparo | Média |
| RF057  | O sistema deve exibir tempo médio de entrega | Média |
| RF058  | O sistema deve permitir exportar relatórios em PDF/Excel | Baixa |
| RF059  | O sistema deve exibir dashboard com indicadores em tempo real | Média |

---

### 2.7 Módulo de Configurações

| **ID** | **Descrição** | **Prioridade** |
|--------|---------------|----------------|
| RF060  | O sistema deve permitir configurar dados do estabelecimento | Alta |
| RF061  | O sistema deve permitir configurar horário de funcionamento | Alta |
| RF062  | O sistema deve permitir configurar tempo estimado de preparo padrão | Média |
| RF063  | O sistema deve permitir configurar categorias de produtos | Média |
| RF064  | O sistema deve permitir gerenciar usuários do sistema | Alta |

---

## 3. Requisitos Não Funcionais (RNF)

### 3.1 Desempenho

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF001 | O sistema deve responder requisições de API em até 500ms (95th percentile) | Desempenho |
| RNF002 | O chat deve ter latência inferior a 100ms na entrega de mensagens | Desempenho |
| RNF003 | O sistema deve suportar 100 usuários simultâneos por instância | Desempenho |
| RNF004 | O sistema deve suportar 1000 pedidos ativos simultaneamente | Desempenho |
| RNF005 | A interface deve carregar completamente em até 3 segundos | Desempenho |

### 3.2 Escalabilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF010 | O sistema deve ser escalável horizontalmente (adicionar mais instâncias) | Escalabilidade |
| RNF011 | O sistema deve utilizar load balancer para distribuição de requisições | Escalabilidade |
| RNF012 | O sistema deve suportar crescimento de 300% de carga sem redesign | Escalabilidade |

### 3.3 Disponibilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF020 | O sistema deve ter disponibilidade de 99% (objetivo acadêmico) | Disponibilidade |
| RNF021 | O sistema deve implementar health checks para monitoramento | Disponibilidade |
| RNF022 | O sistema deve se recuperar automaticamente de falhas em até 5 minutos | Disponibilidade |

### 3.4 Segurança

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF030 | O sistema deve utilizar HTTPS para todas as comunicações | Segurança |
| RNF031 | O sistema deve implementar autenticação JWT com refresh token | Segurança |
| RNF032 | O sistema deve proteger contra ataques CSRF, XSS e SQL Injection | Segurança |
| RNF033 | O sistema deve criptografar dados sensíveis no banco de dados | Segurança |
| RNF034 | O sistema deve implementar rate limiting para prevenir abuso | Segurança |
| RNF035 | O sistema deve registrar logs de auditoria para operações críticas | Segurança |
| RNF036 | Senhas devem ser armazenadas com hash BCrypt (mínimo 10 rounds) | Segurança |

### 3.5 Usabilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF040 | A interface deve ser responsiva (desktop, tablet) | Usabilidade |
| RNF041 | O sistema deve fornecer feedback visual para todas as ações do usuário | Usabilidade |
| RNF042 | O sistema deve seguir padrões de acessibilidade WCAG 2.1 nível AA | Usabilidade |
| RNF043 | A curva de aprendizado deve ser inferior a 2 horas | Usabilidade |
| RNF044 | O sistema deve suportar internacionalização (i18n) | Usabilidade |

### 3.6 Manutenibilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF050 | O código deve ter cobertura de testes de no mínimo 70% | Manutenibilidade |
| RNF051 | O sistema deve seguir princípios SOLID e Clean Code | Manutenibilidade |
| RNF052 | Todas as APIs devem ser documentadas com OpenAPI/Swagger | Manutenibilidade |
| RNF053 | O sistema deve implementar logs estruturados | Manutenibilidade |
| RNF054 | O código deve seguir style guides (Java: Google, JavaScript: Airbnb) | Manutenibilidade |

### 3.7 Portabilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF060 | O sistema deve ser executado em containers Docker | Portabilidade |
| RNF061 | O sistema deve ser orquestrado com Kubernetes | Portabilidade |
| RNF062 | O sistema deve ser agnóstico a provedor cloud | Portabilidade |

### 3.8 Compatibilidade

| **ID** | **Descrição** | **Categoria** |
|--------|---------------|---------------|
| RNF070 | O frontend deve ser compatível com Chrome, Firefox, Edge, Safari (últimas 2 versões) | Compatibilidade |
| RNF071 | O sistema deve suportar integração via API REST | Compatibilidade |
| RNF072 | O sistema deve expor eventos via Kafka para integrações assíncronas | Compatibilidade |

---

## 4. Regras de Negócio (RN)

| **ID** | **Descrição** |
|--------|---------------|
| RN001  | Um pedido só pode ser aceito se todos os produtos estiverem disponíveis |
| RN002  | Um pedido só pode ser recusado dentro de 5 minutos após recebimento |
| RN003  | Um produto com estoque zerado deve ser automaticamente desativado |
| RN004  | O estoque deve ser decrementado automaticamente ao aceitar um pedido |
| RN005  | Um pedido não pode ter status alterado retroativamente (ex: de "Pronto" para "Em Preparo") |
| RN006  | Apenas pedidos no status "Pronto" podem ser atribuídos a entregadores |
| RN007  | Um entregador só pode ter 1 entrega por vez (simplificação acadêmica) |
| RN008  | O chat do pedido deve ser arquivado após 30 dias de finalização |
| RN009  | Pedidos cancelados não devem ser contabilizados em relatórios de vendas |
| RN010  | Produtos excluídos devem ser mantidos em pedidos históricos (soft delete) |
| RN011  | O tempo de preparo estimado deve ser calculado com base no histórico dos últimos 30 dias |
| RN012  | Alertas sonoros devem ser emitidos para pedidos não aceitos em mais de 3 minutos |
| RN013  | O chat deve incluir automaticamente mensagem do sistema ao mudar status do pedido |
| RN014  | Usuários com perfil "Operador" não podem acessar relatórios financeiros |
| RN015  | A senha do usuário deve ter no mínimo 8 caracteres com letras e números |

---

## 5. Casos de Uso Principais

### 5.1 UC01 - Gerenciar Pedido

**Ator Principal**: Operador  
**Pré-condições**: Usuário autenticado, novo pedido recebido  
**Fluxo Principal**:
1. Sistema notifica novo pedido
2. Operador visualiza detalhes do pedido
3. Operador aceita o pedido
4. Sistema atualiza status para "Em Preparo"
5. Sistema decrementa estoque dos produtos
6. Sistema envia notificação ao cliente via chat
7. Operador atualiza status conforme progresso (Pronto → Saiu para Entrega → Finalizado)

**Fluxos Alternativos**:
- **3a.** Operador recusa pedido → Sistema solicita justificativa → Sistema cancela pedido
- **5a.** Produto sem estoque → Sistema exibe alerta → Operador decide se prossegue

---

### 5.2 UC02 - Atribuir Entrega

**Ator Principal**: Despachante  
**Pré-condições**: Pedido no status "Pronto", entregador disponível  
**Fluxo Principal**:
1. Despachante visualiza pedidos prontos
2. Despachante seleciona pedido
3. Sistema exibe lista de entregadores disponíveis
4. Despachante atribui pedido a entregador
5. Sistema adiciona entregador ao chat
6. Sistema atualiza status do pedido para "Saiu para Entrega"
7. Sistema notifica entregador e cliente

---

### 5.3 UC03 - Comunicar via Chat

**Ator Principal**: Operador, Cliente (indiretamente), Entregador  
**Pré-condições**: Pedido criado  
**Fluxo Principal**:
1. Operador acessa chat do pedido
2. Operador digita mensagem
3. Sistema envia mensagem em tempo real
4. Cliente recebe mensagem instantaneamente
5. Cliente responde
6. Sistema exibe resposta ao operador em tempo real

---

## 6. Matriz de Rastreabilidade

| **Requisito** | **Disciplina Relacionada** | **Componente/Tecnologia** |
|---------------|----------------------------|---------------------------|
| RF020-RF029   | Mensageria e Streams       | Kafka, WebSocket          |
| RF040-RF048   | Mensageria e Streams       | STOMP, Redis PubSub       |
| RNF001-RNF005 | Design de Software         | Cache, Índices DB         |
| RNF010-RNF012 | Design de Software         | Microsserviços, K8s       |
| RNF040-RNF044 | Modelagem de UI            | React, Material-UI        |
| RF010-RF019   | Desenvolvimento Web        | REST API, Spring Data     |

---

**Documento elaborado por**: Equipe de Desenvolvimento  
**Data**: Fevereiro de 2026  
**Versão**: 1.0
