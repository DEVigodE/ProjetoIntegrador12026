## 1. Componentes Basicos (sem dependencias)

- [x] 1.1 Criar `src/components/ui/Spinner.tsx` com tamanhos sm, md, lg e animacao CSS
- [x] 1.2 Criar `src/components/ui/Badge.tsx` com variantes de cor (green, yellow, blue, red, gray)
- [x] 1.3 Criar `src/components/ui/Button.tsx` com variantes (primary, secondary, danger), tamanhos (sm, md, lg), loading e disabled

## 2. Componentes de Formulario

- [x] 2.1 Criar `src/components/ui/Input.tsx` com label, placeholder, erro e forwardRef para React Hook Form
- [x] 2.2 Criar `src/components/ui/Select.tsx` com label, opcoes, placeholder, erro e forwardRef para React Hook Form

## 3. Componentes de Dados

- [x] 3.1 Criar `src/components/ui/Table.tsx` generico com generics TypeScript, colunas, dados, ordenacao e linhas clicaveis
- [x] 3.2 Criar `src/components/ui/Pagination.tsx` com navegacao de paginas e destaque da pagina atual
- [x] 3.3 Criar `src/components/ui/EmptyState.tsx` com icone, titulo e descricao

## 4. Componentes de Overlay

- [x] 4.1 Criar `src/components/ui/Modal.tsx` com createPortal, overlay, titulo, conteudo e botao fechar
- [x] 4.2 Criar `src/components/ui/ConfirmDialog.tsx` usando Modal internamente, com titulo, mensagem e botoes Confirmar/Cancelar

## 5. Componentes Compartilhados de Dominio

- [x] 5.1 Criar `src/components/shared/StatusBadge.tsx` com mapeamento centralizado de status (Order, Delivery, Courier) para cores e labels PT-BR
- [x] 5.2 Criar `src/components/shared/OrderCard.tsx` com numero do pedido, cliente, valor em BRL, tempo relativo e onClick
- [x] 5.3 Criar `src/components/shared/AudioAlert.tsx` com Web Audio API (OscillatorNode) ativado pela prop play
