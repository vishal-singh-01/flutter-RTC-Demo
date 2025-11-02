import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/video/presentation/video_call_screen.dart';
import '../features/users/presentation/users_screen.dart';


final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (c, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (c, s) => const LoginScreen(),
    ),
    GoRoute(
      path: '/call',
      builder: (c, s) => const VideoCallScreen(),
    ),
    GoRoute(
      path: '/users',
      builder: (c, s) => const UsersScreen(),
    ),
  ],
);