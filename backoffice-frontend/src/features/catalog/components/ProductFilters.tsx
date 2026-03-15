import { useState, useEffect } from 'react';
import Input from '../../../components/ui/Input';
import Select from '../../../components/ui/Select';
import Button from '../../../components/ui/Button';
import { useCategories } from '../hooks/useCategories';
import type { ProductFilters as ProductFiltersType } from '../types/product.types';

interface ProductFiltersProps {
  filters: ProductFiltersType;
  onFiltersChange: (filters: ProductFiltersType) => void;
}

export default function ProductFilters({ filters, onFiltersChange }: ProductFiltersProps) {
  const { data: categories } = useCategories();
  const [nameInput, setNameInput] = useState(filters.name ?? '');

  useEffect(() => {
    const timer = setTimeout(() => {
      onFiltersChange({ ...filters, name: nameInput || undefined });
    }, 300);
    return () => clearTimeout(timer);
  }, [nameInput]);

  const categoryOptions = [
    { value: '', label: 'Todas as categorias' },
    ...(categories?.filter((c) => c.active).map((c) => ({
      value: String(c.id),
      label: c.name,
    })) ?? []),
  ];

  const availabilityOptions = [
    { value: '', label: 'Todos' },
    { value: 'true', label: 'Disponivel' },
    { value: 'false', label: 'Indisponivel' },
  ];

  return (
    <div className="flex flex-wrap items-end gap-4">
      <div className="w-64">
        <Input
          label="Buscar por nome"
          placeholder="Ex: Pizza..."
          value={nameInput}
          onChange={(e) => setNameInput(e.target.value)}
        />
      </div>
      <div className="w-48">
        <Select
          label="Categoria"
          options={categoryOptions}
          value={filters.categoryId ? String(filters.categoryId) : ''}
          onChange={(e) =>
            onFiltersChange({
              ...filters,
              categoryId: e.target.value ? Number(e.target.value) : undefined,
            })
          }
        />
      </div>
      <div className="w-48">
        <Select
          label="Disponibilidade"
          options={availabilityOptions}
          value={filters.available !== undefined ? String(filters.available) : ''}
          onChange={(e) =>
            onFiltersChange({
              ...filters,
              available: e.target.value ? e.target.value === 'true' : undefined,
            })
          }
        />
      </div>
      <Button
        variant="secondary"
        size="sm"
        onClick={() => {
          setNameInput('');
          onFiltersChange({});
        }}
      >
        Limpar filtros
      </Button>
    </div>
  );
}
