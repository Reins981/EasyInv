// lib/main.dart
import 'package:easy_inv/screens/asset_management_screen.dart';
import 'package:easy_inv/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'utils/colors.dart';


class AppLifecycleObserver with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App is about to enter state $state');
    }
  }
}

AppLifecycleObserver observer = AppLifecycleObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SearchProvider(FirestoreService()),
        ),
      ],
      child: MaterialApp(
        title: 'Inventory Management',
        theme: ThemeData(
          primaryColor: AppColors.rosa,
          hintColor: AppColors.pink,
          scaffoldBackgroundColor: AppColors.white,
        ),
        home: DashboardScreen(),
        routes: {
          //'/login': (context) => LoginScreen(docOperations: docOperations),
          '/dashboard': (context) => DashboardScreen(),
          '/asset_management': (context) => AssetManagementScreen(),
          //'/biometric': (context) => AuthenticatedScreen(),
          //'/registration': (context) => const RegistrationScreen(),
          // ... other routes
        },
      ),
    );
  }
}
