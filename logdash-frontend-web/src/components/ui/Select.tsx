import { forwardRef, type SelectHTMLAttributes } from 'react';

interface SelectOption {
  value: string;
  label: string;
}

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
  options: SelectOption[];
  placeholder?: string;
}

const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, options, placeholder, id, className = '', ...rest }, ref) => {
    const selectId = id || rest.name;

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
          {...rest}
        >
          {placeholder && (
            <option value="" disabled>
              {placeholder}
            </option>
          )}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
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

Select.displayName = 'Select';

export default Select;
