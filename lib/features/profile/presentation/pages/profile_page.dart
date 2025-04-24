// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_event.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;
  bool _enableFingerPrint = false;
  final _auth = LocalAuthentication();
  String? _savedToken;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    String? darkMode = await _storage.read(key: 'dark_mode');
    String? fingerPrintEnabled = await _storage.read(key: 'finger_print_enabled');
    bool isDarkMode = darkMode == '1' ? true : false;
    bool isFingerprintEnabled = fingerPrintEnabled == '1' ? true : false;
    setState(() {
      _isDarkMode = isDarkMode;
      _enableFingerPrint = isFingerprintEnabled;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
      _setDarkMode(value);
    });
  }

  Future<void> _setDarkMode(bool value) async {
    await _storage.write(key: 'dark_mode', value: value ? "1" : "0");
  }

  Future<void> _toggleEnableFingerPrint(bool value) async {
    setState(() {
      _loginWithFingerprint(value);
    });
  }

  Future<void> _loginWithFingerprint(bool value) async {
    final canAuth = await _auth.canCheckBiometrics;
    if (!canAuth || !mounted) return;

    try {
      final didAuth = await _auth.authenticate(
        localizedReason: 'Login with fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!mounted) return;
      if (didAuth) {
        _enableFingerPrint = value;
        await _storage.write(key: 'finger_print_enabled', value: value ? '1' : '0');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint authentication failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: MainLayout(
        title: 'Profile',
        titleIcon: const Icon(Icons.person),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final userName = state.user?['data']['name'] ?? 'Unknown User';
            final email = state.user?['data']['email'] ?? 'No email provided';

            return Column(
              children: [
                Container(
                  color: const Color(0xFFE6E6FA),
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: const NetworkImage(
                        'https://pbs.twimg.com/profile_images/1513741421937045504/8fEVPrh7_400x400.jpg',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Profile image error: $exception');
                      },
                      child: state.user == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email Address', email),
                      const Divider(height: 32),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.nightlight_round, size: 20),
                                SizedBox(width: 8),
                                Text('Dark mode', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Switch(
                              value: _isDarkMode,
                              onChanged: _toggleDarkMode,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      _buildMenuItem(Icons.settings, 'Settings', () {
                        debugPrint('Settings tapped');
                        // TODO: Navigasi ke halaman pengaturan
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.fingerprint, size: 20),
                                SizedBox(width: 8),
                                Text('Active Finger Print', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Switch(
                              value: _enableFingerPrint,
                              onChanged: _toggleEnableFingerPrint,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      _buildMenuItem(Icons.logout, 'Log out', () {
                        debugPrint('Logout tapped from ProfilePage');
                        context.read<AuthBloc>().add(const LogoutRequested());
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}