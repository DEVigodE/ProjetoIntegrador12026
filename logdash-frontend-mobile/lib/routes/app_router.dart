import 'package:go_router/go_router.dart';
import 'package:logdash_frontend_mobile/app/app_module.dart';
import 'package:logdash_frontend_mobile/features/auth/data/auth_repository.dart';
import 'package:logdash_frontend_mobile/features/auth/ui/login_page.dart';
import 'package:logdash_frontend_mobile/features/auth/ui/register_page.dart';
import 'package:logdash_frontend_mobile/features/cart/ui/cart_page.dart';
import 'package:logdash_frontend_mobile/features/catalog/ui/home_client_page.dart';
import 'package:logdash_frontend_mobile/features/chat/ui/chat_page.dart';
import 'package:logdash_frontend_mobile/features/home/ui/home_page.dart';
import 'package:logdash_frontend_mobile/features/orders/ui/checkout_page.dart';
import 'package:logdash_frontend_mobile/features/orders/ui/my_orders_page.dart';
import 'package:logdash_frontend_mobile/features/orders/ui/order_tracking_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: injector.get<AuthRepository>(),
  redirect: (context, state) {
    final authRepo = injector.get<AuthRepository>();
    final isAuth = authRepo.isAuthenticated;
    final user = authRepo.currentUser.value;
    final path = state.matchedLocation;
    const publicPaths = ['/login', '/register'];

    if (!isAuth && !publicPaths.contains(path)) return '/login';
    if (isAuth && publicPaths.contains(path)) {
      return user?.isClient == true ? '/home-client' : '/';
    }
    if (isAuth && user?.isClient == true && path == '/') {
      return '/home-client';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/home-client',
      name: 'home-client',
      builder: (context, state) => const HomeClientPage(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/my-orders',
      name: 'my-orders',
      builder: (context, state) => const MyOrdersPage(),
    ),
    GoRoute(
      path: '/order/:id',
      name: 'order-tracking',
      builder: (context, state) => OrderTrackingPage(
        orderId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/chat/:orderId',
      name: 'chat',
      builder: (context, state) => ChatPage(
        orderId: int.parse(state.pathParameters['orderId']!),
      ),
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
