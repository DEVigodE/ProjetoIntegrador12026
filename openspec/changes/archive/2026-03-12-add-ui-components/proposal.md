## Why

O layout base e roteamento ja estao implementados, mas as paginas de features (dashboard, catalogo, pedidos, entregas, relatorios, configuracoes) dependem de componentes UI genericos reutilizaveis que ainda nao existem. Sem esses componentes, cada feature precisaria reimplementar botoes, inputs, modais, tabelas e badges, gerando duplicacao e inconsistencia visual.

## What Changes

- Criar componentes genericos em `src/components/ui/`: Button, Input, Select, Modal, Badge, Spinner, Table, Pagination, ConfirmDialog, EmptyState
- Criar componentes compartilhados em `src/components/shared/`: StatusBadge, OrderCard, AudioAlert
- Todos os componentes tipados com TypeScript (sem `any`), estilizados com TailwindCSS
- Integracao do Input e Select com React Hook Form via `forwardRef`
- Validacao visual de erros nos campos de formulario
- AudioAlert usando Web Audio API (sem arquivos de audio externos)

## Capabilities

### New Capabilities
- `ui-components`: Componentes genericos reutilizaveis da biblioteca interna de UI (Button, Input, Select, Modal, Badge, Spinner, Table, Pagination, ConfirmDialog, EmptyState, StatusBadge, OrderCard, AudioAlert)

### Modified Capabilities

## Impact

- **Codigo**: Novos arquivos em `src/components/ui/` e `src/components/shared/`
- **Dependencias**: Utiliza React Hook Form, Zod, e Web Audio API (ja instalados)
- **Features**: Desbloqueia a implementacao de todas as paginas de features (dashboard, catalogo, pedidos, entregas, relatorios, configuracoes)
