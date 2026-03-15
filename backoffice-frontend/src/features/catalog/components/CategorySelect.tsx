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
            className="mb-1 block text-sm font-medium text-gray-700"
          >
            {label}
          </label>
        )}
        <select
          ref={ref}
          id={selectId}
          className={`block w-full rounded-md border px-3 py-2 text-sm shadow-sm transition-colors focus:outline-none focus:ring-2 focus:ring-primary-500 ${
            error
              ? 'border-red-500 focus:border-red-500 focus:ring-red-500'
              : 'border-gray-300 focus:border-primary-500'
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
            className="mt-1 text-sm text-red-600"
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
