interface Breadcrumb {
  label: string;
  path?: string;
}

interface PageHeaderProps {
  title: string;
  breadcrumbs?: Breadcrumb[];
}

export default function PageHeader({ title, breadcrumbs }: PageHeaderProps) {
  return (
    <div className="mb-6">
      {breadcrumbs && breadcrumbs.length > 0 && (
        <nav className="text-sm text-gray-600 mb-1">
          {breadcrumbs.map((crumb, index) => (
            <span key={crumb.label}>
              {index > 0 && <span className="mx-1">/</span>}
              <span>{crumb.label}</span>
            </span>
          ))}
        </nav>
      )}
      <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
    </div>
  );
}
