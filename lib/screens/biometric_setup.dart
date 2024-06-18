import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../services/firestore_service.dart';


/// Class representing the Authentication Screen
class AuthenticatedScreen extends StatefulWidget {
  @override
  _AuthenticatedScreenState createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final Helper _helper = Helper();

  @override
  void initState() {
    super.initState();
  }

  /// Perform a delayed operation
  ///
  /// - [seconds] delay in seconds [int]
  Future<void> delay(int seconds) async {
    // Sleep for x seconds
    await Future.delayed(Duration(seconds: seconds));
  }

  /// Check if the biometric feature is available on this phone
  ///
  /// - [context] current context [ScaffoldMessengerState]
  ///
  /// Returns: true or false [bool]
  Future<bool> _checkBiometric(ScaffoldMessengerState context) async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _helper.showSnackBar('$e', "Error", context);
    }

    if (!canCheckBiometric) {
      _helper.showSnackBar("No está disponible la autenticación biométrica en este dispositivo!", "Error", context);
    }

    return canCheckBiometric;
  }

  /// Get the available biometric features on this phone
  ///
  /// - [context] current context [ScaffoldMessengerState]
  ///
  /// Returns: true or false [bool]
  Future<bool> _getAvailableBiometric(ScaffoldMessengerState context) async {
    bool success = false;

    try {
      List<BiometricType> availableBiometric = await auth.getAvailableBiometrics();
      success = availableBiometric.isNotEmpty ? true : false;
    } on PlatformException catch (e) {
      _helper.showSnackBar('$e', "Error", context);
    }

    return success;
  }

  /// Authenticate a user using the biometric fingerprint feature if available
  ///
  /// - [context] current context [ScaffoldMessengerState]
  ///
  /// Returns: true or false [bool]
  Future<bool> _authenticate(BuildContext context) async {
    final scaffoldContext = ScaffoldMessenger.of(context);

    if (!await _checkBiometric(scaffoldContext)) {
      return false;
    }

    if (!await _getAvailableBiometric(scaffoldContext)) {
      return false;
    }

    try {
      Map<String, dynamic> _ = await _helper.getCurrentUserDetails(
          forceRefresh: true);
    } catch(e) {
      _helper.showSnackBar(e.toString(), 'Error', scaffoldContext);
      return false;
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Autentíquese para acceder a la aplicación',
      );
    } on PlatformException catch (e) {
      _helper.showSnackBar('$e', "Error", scaffoldContext);
      return false;
    }

    if (authenticated) {
      // Navigate to another screen upon successful authentication
      _helper.showSnackBar("Autenticación exitosa!", "Success", scaffoldContext, duration: 1);
      // Execute cleanupOldSalesData on app start
      await cleanupOldSalesData();
      return true;
    } else {
      _helper.showSnackBar("Autenticación fallida!", "Error", scaffoldContext);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _helper.getCurrentUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _helper.showStatus('Error al cargar los datos: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return _helper.showStatus('No hay datos de usuario disponibles!');
        }

        Map<String, dynamic> userDetails = snapshot.data!;
        String userName = userDetails['userEmail'].substring(0, userDetails['userEmail'].indexOf('@'));

        return Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Bienvenido $userName',
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        const Icon(
                          Icons.fingerprint,
                          size: 100.0,
                          color: AppColors.pink,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          'Autentícate usando tu huella digital en lugar de tu contraseña.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.grey,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        ElevatedButton(
                          onPressed: () async {
                            bool success = await _authenticate(context);
                            await delay(1);
                            if (success) {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.rosa,
                            backgroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          child: Text(
                            'Autenticar',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              color: AppColors.rosa,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
