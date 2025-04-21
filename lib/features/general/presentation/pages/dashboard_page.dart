import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';
import 'package:yukngantri/core/theme/app_colors.dart';
import 'package:yukngantri/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yukngantri/features/auth/presentation/pages/login.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/line_chart.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late bool isShowingMainData = true;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
        child: MainLayout(
          title: "Dashboard",
          titleIcon: Icon(Icons.dashboard),
          child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.user == null && !state.isLoading) {
                  // Jika pengguna tidak terautentikasi, arahkan ke LoginPage
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                }
              },
              builder: (context, state) {
                if (state.isLoading || state.user == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return AspectRatio(
                  aspectRatio: 1.23,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Welcome, ${state.user!['data']['name'] ?? 'User'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                isShowingMainData = !isShowingMainData;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Monthly Sales',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 37),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, left: 6),
                          child: LineChartWidget(isShowingMainData: isShowingMainData),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                );
              }
          ),
        )
    );
  }
}
