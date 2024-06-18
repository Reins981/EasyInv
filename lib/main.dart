// lib/main.dart
import 'dart:async';

import 'package:easy_inv/screens/asset_management_screen.dart';
import 'package:easy_inv/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login.dart';
import 'utils/colors.dart';
import 'services/biometric_service.dart';
import 'screens/biometric_setup.dart';


class AppLifecycleObserver with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App is about to enter state $state');
      cleanupOldSalesData();
    }
  }
}

AppLifecycleObserver observer = AppLifecycleObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(observer);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsEnabled();
  }

  Future<void> _checkBiometricsEnabled() async {
    // Check if biometrics are enabled for the user
    // Fetch from shared preferences
    bool biometricsEnabled = await BiometricsService.getBiometricsEnabled();

    setState(() {
      _biometricsEnabled = biometricsEnabled;
    });
  }

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
        home: LoadingPage(biometricsEnabled: _biometricsEnabled),
        routes: {
          '/login': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/asset_management': (context) => AssetManagementScreen(),
          '/biometric': (context) => AuthenticatedScreen(),
          // ... other routes
        },
      ),
    );
  }
}

class LoadingPage extends StatefulWidget {

  final bool biometricsEnabled;

  LoadingPage({Key? key, required this.biometricsEnabled});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    Timer(const Duration(seconds: 2), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && widget.biometricsEnabled) {
        // User is signed in and biometrics have been enabled
        Navigator.pushReplacementNamed(context, '/biometric');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: const FlutterLogo(size: 150),
        ),
      ),
    );
  }
}
