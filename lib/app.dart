import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yukngantri/core/network/api_service.dart';
import 'package:yukngantri/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/merchants/domain/repositories/merchant_repository_impl.dart';
import 'features/merchants/presentation/bloc/merchant_bloc.dart';
import 'features/users/domain/repositories/user_repository_impl.dart';
import 'features/users/presentation/bloc/user_bloc.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => UserRepositoryImpl(
            apiService: ApiService(),
            storage: const FlutterSecureStorage(),
          ),
        ),
        RepositoryProvider(
          create: (context) => MerchantRepositoryImpl(
            apiService: ApiService(),
            storage: const FlutterSecureStorage(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              apiService: ApiService(),
              storage: const FlutterSecureStorage(),
            ),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              repository: RepositoryProvider.of<UserRepositoryImpl>(context),
            ),
          ),
          BlocProvider(
            create: (context) => MerchantBloc(
              repository: RepositoryProvider.of<MerchantRepositoryImpl>(context),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Aplikasi Antrian Digital',
          theme: ThemeData(primarySwatch: Colors.blue),
          onGenerateRoute: AppRoutes.generateRoute,
          builder: (context, child) {
            return SafeArea(
              child: child!,
            );
          },
        ),
      ),
    );
  }
}