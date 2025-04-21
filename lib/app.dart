import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/network/api_service.dart';
import 'package:yukngantri/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => AuthBloc(
                apiService: ApiService(),
                storage: const FlutterSecureStorage(),
              ),
        ),
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => UsersController()),
        // ChangeNotifierProvider(create: (_) => MerchantsController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Antrian Digital',
        theme: ThemeData(primarySwatch: Colors.blue),
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          return SafeArea(
            child: child!, // Pastikan konten berada di dalam SafeArea
          );
        },
      ),
    );
  }
}
