import Select from '../../../components/ui/Select';
import type { OrderStatus } from '../types/order.types';

interface OrderFiltersProps {
  status: OrderStatus | '';
  onStatusChange: (status: OrderStatus | '') => void;
}

const statusOptions = [
  { value: '', label: 'Todos os status' },
  { value: 'PENDING', label: 'Pendente' },
  { value: 'ACCEPTED', label: 'Aceito' },
  { value: 'PREPARING', label: 'Em Preparo' },
  { value: 'READY', label: 'Pronto' },
  { value: 'OUT_FOR_DELIVERY', label: 'Saiu para Entrega' },
  { value: 'DELIVERED', label: 'Entregue' },
  { value: 'CANCELLED', label: 'Cancelado' },
];

export default function OrderFilters({ status, onStatusChange }: OrderFiltersProps) {
  return (
    <div className="flex items-end gap-4">
      <div className="w-48">
        <Select
          label="Status"
          options={statusOptions}
          value={status}
          onChange={(e) => onStatusChange(e.target.value as OrderStatus | '')}
        />
      </div>
    </div>
  );
}
