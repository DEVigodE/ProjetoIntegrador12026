import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/auth/ui/login_page.dart';
import 'package:logdash_frontend_mobile/features/auth/ui/register_page.dart';
import 'package:logdash_frontend_mobile/features/home/ui/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: injector.get<AuthRepository>(),
  redirect: (context, state) {
    final isAuth = injector.get<AuthRepository>().isAuthenticated;
    final path = state.matchedLocation;
    const publicPaths = ['/login', '/register'];

    if (!isAuth && !publicPaths.contains(path)) return '/login';
    if (isAuth && publicPaths.contains(path)) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
  ],
);
