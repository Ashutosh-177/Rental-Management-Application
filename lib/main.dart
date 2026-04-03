import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/property_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/rent_service.dart';
import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/tenant/tenant_dashboard.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PropertyService()),
        ChangeNotifierProvider(create: (_) => StorageService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => RentService()),
      ],
      child: const RentCollectApp(),
    ),
  );
}

class RentCollectApp extends StatelessWidget {
  const RentCollectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Rent Collect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = authService.userModel;
          if (user == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (user.role == UserRole.owner) {
            return const OwnerDashboard();
          } else {
            return const TenantDashboard();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
