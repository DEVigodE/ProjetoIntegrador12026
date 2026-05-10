import { forwardRef, type SelectHTMLAttributes } from 'react';
import { useCategories } from '../hooks/useCategories';

interface CategorySelectProps extends Omit<SelectHTMLAttributes<HTMLSelectElement>, 'children'> {
  label?: string;
  error?: string;
  placeholder?: string;
}

const CategorySelect = forwardRef<HTMLSelectElement, CategorySelectProps>(
  ({ label, error, placeholder = 'Selecione uma categoria', id, className = '', ...rest }, ref) => {
    const { data: categories, isLoading } = useCategories();
    const selectId = id || rest.name;

    const activeCategories = categories?.filter((c) => c.active) ?? [];

    return (
      <div className="w-full">
        {label && (
          <label
            htmlFor={selectId}
            className="mb-1 block text-xs font-semibold uppercase tracking-wide text-gray-500"
          >
            {label}
          </label>
        )}
        <select
          ref={ref}
          id={selectId}
          className={`block w-full rounded-lg border px-3 py-2 text-sm text-gray-900 shadow-[0_10px_24px_-18px_rgba(15,23,42,0.35)] transition-colors focus:outline-none focus:ring-2 focus:ring-orange-300/70 ${
            error
              ? 'border-red-400 focus:border-red-400 focus:ring-red-300/70'
              : 'border-gray-200/80 focus:border-orange-300'
          } ${className}`}
          aria-invalid={!!error}
          aria-describedby={error && selectId ? `${selectId}-error` : undefined}
          disabled={isLoading}
          {...rest}
        >
          <option value="">
            {isLoading ? 'Carregando...' : placeholder}
          </option>
          {activeCategories.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {cat.name}
            </option>
          ))}
        </select>
        {error && (
          <p
            id={selectId ? `${selectId}-error` : undefined}
            className="mt-1 text-xs font-medium text-red-600"
          >
            {error}
          </p>
        )}
      </div>
    );
  }
);

CategorySelect.displayName = 'CategorySelect';

export default CategorySelect;
