import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_pro/config/theme.dart';
import 'package:service_pro/config/routes.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/service_request_provider.dart';
import 'package:service_pro/providers/customer_provider.dart';
import 'package:service_pro/providers/staff_provider.dart';
import 'package:service_pro/providers/reminder_provider.dart';

/// The root application widget for Service Pro
class ServiceProApp extends StatelessWidget {
  const ServiceProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        title: 'Service Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
