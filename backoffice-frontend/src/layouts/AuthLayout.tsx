export default function AuthLayout() {
  return (
    <div className="flex items-center justify-center h-screen bg-gray-50">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500 mx-auto" />
        <p className="mt-4 text-gray-600">Autenticando...</p>
      </div>
    </div>
  );
}
