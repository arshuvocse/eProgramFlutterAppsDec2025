
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:e_program_apps/view/data_sync_view.dart';
import 'package:e_program_apps/view/dashboard_view.dart';
import 'package:e_program_apps/view/login_view.dart';
import 'package:e_program_apps/view/attendance_view.dart';
import 'package:e_program_apps/view/splash_screen.dart';
import 'package:e_program_apps/viewmodel/session_viewmodel.dart';
import 'package:e_program_apps/services/location_tracking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locationService = LocationTrackingService();
  await locationService.init();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
     GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/attendance',
      builder: (BuildContext context, GoRouterState state) {
        return const AttendanceView();
      },
    ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/data-sync',
      builder: (BuildContext context, GoRouterState state) {
        return const DataSyncScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'Flutter MVVM Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}
