import 'package:yukngantri/features/auth/presentation/pages/login.dart';
import 'package:yukngantri/features/general/presentation/pages/splash_page.dart';
import 'package:yukngantri/features/general/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:yukngantri/features/profile/presentation/pages/profile_page.dart';
import 'package:yukngantri/features/users/presentation/pages/users_page.dart';
import 'package:yukngantri/features/merchants/presentation/pages/merchants_page.dart';
import 'package:yukngantri/features/maps/presentation/pages/maps_page.dart';
import 'package:yukngantri/features/news/presentation/pages/news_page.dart';
//
// final routes = {
//   '/': (context) => const SplashPage(),
//   '/dashboard': (context) => const DashboardPage(),
//   // '/profile': (context) => const ProfilePage(),
//   // '/merchants': (context) => const MerchantsPage(),
//   // '/users': (context) => const UsersPage(),
//   // '/news': (context) => const NewsPage(),
//   // '/map-playground': (context) => const MapPlayground(),
//   '/login': (context) => const LoginPage(),
// };

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.routeName:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case LoginPage.routeName:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case DashboardPage.routeName:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case MerchantsPage.routeName:
        return MaterialPageRoute(builder: (_) => const MerchantsPage());
      case UsersPage.routeName:
        return MaterialPageRoute(builder: (_) => const UsersPage());
      case ProfilePage.routeName:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case MapPlayground.routeName:
        return MaterialPageRoute(builder: (_) => const MapPlayground());
      case NewsPage.routeName:
        return MaterialPageRoute(builder: (_) => const NewsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rute tidak ditemukan')),
          ),
        );
    }
  }
}