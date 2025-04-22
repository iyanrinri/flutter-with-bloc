import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_event.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_state.dart';
import 'package:yukngantri/features/auth/presentation/pages/login.dart';

class MainLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final Icon? titleIcon;

  const MainLayout({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.titleIcon,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.user == null && !state.isLoading) {
          Navigator.pushReplacementNamed(context, LoginPage.routeName);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = state.user;
          return Scaffold(
            appBar: _buildAppBar(widget.title),
            drawer: _buildDrawer(context, user),
            floatingActionButton: widget.floatingActionButton,
            body: SafeArea(child: widget.child),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: widget.titleIcon ?? _logo(),
          ),
          Text(title),
        ],
      ),
    );
  }

  ClipRRect _logo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(75),
      child: Image.asset(
        _AppConstants.appIconPath,
        width: 38,
        height: 38,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, Map<String, dynamic>? user) {
    final currentRole = user?['data']['role']?.toString().toUpperCase() ?? 'USER';
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),
                _buildDrawerItem(context, Icons.store, 'Merchants', '/merchants'),
                if (currentRole == 'ADMIN')
                  _buildDrawerItem(context, Icons.people, 'Users', '/users'),
                _buildDrawerItem(context, Icons.newspaper, 'News', '/news'),
                _buildDrawerItem(context, Icons.map, 'Map Playground', '/map-playground'),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          _buildDrawerItem(context, Icons.person, 'Profile', '/profile'),
          _buildLogoutItem(context),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset(
              _AppConstants.appIconPath,
              width: 38,
              height: 38,
            ),
          ),
          const Text(
            "Yuk Antri",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }

  ListTile _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () async {
        context.read<AuthBloc>().add(const LogoutRequested());
        Navigator.pop(context); // Tutup drawer
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      },
    );
  }
}

class _AppConstants {
  static const String appIconPath = 'assets/icon/app_icon.png';
}