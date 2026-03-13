## Context

O backoffice frontend ja possui layout base (MainLayout, Sidebar, Header) e roteamento com guards de autenticacao e roles. As paginas de features estao criadas como placeholders. Para implementar as funcionalidades reais, e necessario um conjunto de componentes UI reutilizaveis que garantam consistencia visual e reduzam duplicacao.

A stack ja inclui TailwindCSS para estilizacao, React Hook Form + Zod para formularios, e todas as dependencias estao instaladas.

## Goals / Non-Goals

**Goals:**
- Criar componentes genericos (`src/components/ui/`) com API simples e tipagem completa
- Criar componentes compartilhados de dominio (`src/components/shared/`) para status e pedidos
- Garantir integracao nativa com React Hook Form nos componentes de formulario (Input, Select)
- Seguir o tema visual definido no CLAUDE.md (primary-500 laranja, sidebar slate-800)

**Non-Goals:**
- Nao implementar Storybook ou documentacao visual dos componentes
- Nao criar testes unitarios nesta fase (serao adicionados junto com as features)
- Nao criar componentes de feature especificos (KpiCard, ProductTable, etc.)
- Nao implementar responsividade mobile — foco desktop (1280px+)

## Decisions

### 1. Componentes de formulario com forwardRef
Input e Select usarao `React.forwardRef` para compatibilidade direta com `register()` do React Hook Form, sem necessidade de Controller wrapper.

**Alternativa considerada**: Usar `Controller` do RHF — rejeitado por adicionar boilerplate desnecessario para inputs simples.

### 2. Table generico com generics TypeScript
O componente Table aceitara `columns` e `data` tipados com generics (`Table<T>`), permitindo type-safety nas funcoes de render das colunas.

**Alternativa considerada**: Table sem generics usando `any` — rejeitado pela restricao de nao usar `any`.

### 3. Modal com Portal
Modal renderizara via `createPortal` no `document.body` para evitar problemas de z-index e overflow hidden em containers pais.

**Alternativa considerada**: Modal inline sem portal — rejeitado por causar problemas de stacking context em layouts complexos.

### 4. AudioAlert com Web Audio API
Gerar tom programaticamente via OscillatorNode ao inves de usar arquivo de audio externo, mantendo o bundle leve e sem assets adicionais.

### 5. StatusBadge com mapeamento centralizado
Um unico objeto mapeia cada status (OrderStatus, DeliveryStatus, CourierStatus) para cor e label em PT-BR, facilitando manutencao quando o backend adicionar novos status.

## Risks / Trade-offs

- **[API do Table pode ser complexa]** → Manter API minima (columns, data, onRowClick, onSort) e expandir conforme necessidade das features
- **[AudioAlert pode ser bloqueado pelo navegador]** → Web Audio API requer interacao do usuario antes do primeiro som; o fluxo normal do app (login via Keycloak) garante isso
- **[Componentes podem precisar de ajustes ao integrar com features]** → API dos componentes foi desenhada com base nos cenarios reais das specs de features, minimizando retrabalho
