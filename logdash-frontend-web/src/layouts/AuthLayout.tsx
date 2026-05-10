export default function AuthLayout() {
  return (
    <div className="flex h-screen items-center justify-center bg-gradient-to-br from-gray-50 via-white to-orange-50/40">
      <div className="text-center">
        <div className="mx-auto h-12 w-12 animate-spin rounded-full border-b-2 border-orange-500" />
        <p className="mt-4 text-gray-600">Autenticando...</p>
      </div>
    </div>
  );
}
