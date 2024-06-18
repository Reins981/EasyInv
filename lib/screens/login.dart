import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../screens/dashboard_screen.dart';
import '../services/biometric_service.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Helper _helper = Helper();
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showEmailInputDialog(BuildContext context) async {
    TextEditingController _emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: const Text(
              'Restablecer contraseña',
              style: TextStyle(color: AppColors.rosa)
          ),
          // Change text color to rosa
          content: TextField(
            controller: _emailController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Ingrese su dirección de correo electrónico',
              labelStyle: const TextStyle(color: AppColors.pink),
              // Customize label text color
              fillColor: AppColors.rosa,
              // Fill color of the text field
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none, // No border
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border when focused
                borderRadius: BorderRadius.circular(30.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border for error
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // No border for error when focused
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                Navigator.of(context).pop();
                await resetPassword(email, context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.rosa, // Text color
              ),
              child: Text(
                'Send',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.sendPasswordResetEmail(email: email);
      _helper.showSnackBar("Se ha enviado una notificación a su cuenta de correo electrónico.", "Success", scaffoldContext, duration: 6);
    } catch (e) {
      _helper.showSnackBar('$e', "Error", scaffoldContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/logo.jpg',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.black),
                        labelText: 'Correo electrónico',
                        labelStyle: GoogleFonts.lato(color: Colors.black),
                        fillColor: AppColors.rosa,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                        labelText: 'Contraseña',
                        labelStyle: GoogleFonts.lato(color: Colors.black),
                        fillColor: AppColors.rosa,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: Text(
                        "Activar Biometría",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                      value: _biometricsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricsEnabled = value;
                        });
                      },
                      activeColor: AppColors.pink, // Set the active color to rosa (pink)
                      inactiveThumbColor: AppColors.rosa, // Optional: set the inactive thumb color
                      inactiveTrackColor: AppColors.rosa, // Optional: set the inactive track color
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _biometricsEnabled
                          ? () async {
                        await _handleLogin(context, true);
                      }
                          : () async {
                        await _handleLogin(context, false);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.rosa,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        'Iniciar sesión',
                        style: GoogleFonts.lato(
                          color: AppColors.rosa,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5, // Space between buttons
                      runSpacing: 5, // Additional space if buttons wrap to the next line
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _showEmailInputDialog(context);
                          },
                          child: Text(
                            "Cambiar contraseña",
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, bool preserveAuthenticationState) async {
    ScaffoldMessengerState scaffoldContext = ScaffoldMessenger.of(context);

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        _helper.showSnackBar("Por favor ingresa tanto el correo electrónico como la contraseña.", 'Error', scaffoldContext);
        return;
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = userCredential.user!;

      if (preserveAuthenticationState) {
        print("Persist Authentication state");
        BiometricsService.setBiometricsEnabled(true);
      } else {
        print("Authentication state will not be preserved");
        BiometricsService.setBiometricsEnabled(false);
      }

      _showWelcomeAnimation(context, user.email!.substring(0, user.email!.indexOf('@')));
    } catch (e) {
      String errorMessage = "Ocurrió un error durante el inicio de sesión!";
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      _helper.showSnackBar(errorMessage, 'Error', scaffoldContext);
    }
  }

  void _showWelcomeAnimation(BuildContext context, String displayName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _WelcomeDialog(displayName: displayName);
      },
    );
  }
}

class _WelcomeDialog extends StatefulWidget {
  final String displayName;

  _WelcomeDialog({Key? key, required this.displayName}) : super(key: key);

  @override
  _WelcomeDialogState createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<_WelcomeDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
    // Execute cleanupOldSalesData on app start
    cleanupOldSalesData().then((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
      builder: (context, child) {
        return Transform.scale(
          scale: _controller.value,
          child: Opacity(
            opacity: _controller.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Bienvenido ${widget.displayName}!",
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.rosa,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: Text(
                        "Continuar",
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
          ),
        );
      },
    );
  }
}
