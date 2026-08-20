import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/auth/presentation/pages/login_page.dart';
import 'package:yemen_daleeli/features/auth/presentation/pages/signup_page.dart';
import 'package:yemen_daleeli/features/home/presentation/pages/home_page.dart';
import 'package:yemen_daleeli/features/auth/presentation/pages/splash_page.dart';
import 'package:yemen_daleeli/features/categories/presentation/pages/categories_page.dart';
import 'package:yemen_daleeli/features/services/presentation/pages/services_page.dart';
import 'package:yemen_daleeli/features/services/presentation/pages/service_details_page.dart';
import 'package:yemen_daleeli/features/services/presentation/pages/favorites_page.dart';
import 'package:yemen_daleeli/features/auth/presentation/pages/profile_page.dart';
import 'package:yemen_daleeli/features/reviews/presentation/pages/add_review_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      return authState.when(
        data: (user) {
          if (isSplash || isAuth) return '/home';
          
          // حماية المسارات التي تتطلب تسجيل دخول فعلي (ليس ضيف)
          final protectedRoutes = ['/favorites', '/profile', '/add-review'];
          final isProtected = protectedRoutes.any((route) => state.matchedLocation.startsWith(route));
          
          if (isProtected && (user == null || user.role.name == 'guest')) {
            return '/login';
          }
          
          return null;
        },
        loading: () => isSplash ? null : '/splash',
        error: (_, __) => isAuth ? null : '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          final categoryName = state.uri.queryParameters['categoryName'];
          return ServicesPage(categoryId: categoryId, categoryName: categoryName);
        },
      ),
      GoRoute(
        path: '/service-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ServiceDetailsPage(serviceId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/add-review/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return AddReviewPage(serviceId: serviceId);
        },
      ),
    ],
  );
});
