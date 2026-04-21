import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/require_auth.dart';
import 'features/home/home_screen.dart';
import 'features/explore/explore_screen.dart';
import 'features/portfolio/portfolio_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/stock/stock_detail_screen.dart';
import 'providers/theme_provider.dart';
import 'widgets/bottom_nav_bar.dart';

class PulseApp extends ConsumerWidget {
  const PulseApp({super.key});

  static const _tabRoutes = ['/home', '/explore', '/portfolio', '/profile'];

  static final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return RequireAuth(
            child: _TabScaffold(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HomeScreen(
                onStockTap: (id) => context.push('/stock/$id'),
              ),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ExploreScreen(
                onStockTap: (id) => context.push('/stock/$id'),
              ),
            ),
          ),
          GoRoute(
            path: '/portfolio',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PortfolioScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/stock/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            child: RequireAuth(
              child: StockDetailScreen(stockId: id),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider).themeMode;

    return MaterialApp.router(
      title: 'Ledger — Ethereal Invest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

class _TabScaffold extends StatelessWidget {
  final Widget child;

  const _TabScaffold({required this.child});

  int _currentIndexFromLocation(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/portfolio')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          context.go(PulseApp._tabRoutes[index]);
        },
      ),
    );
  }
}






