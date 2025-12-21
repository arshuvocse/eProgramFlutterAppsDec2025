
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to handle login logic and navigation
  Future<void> _login(LoginViewModel viewModel) async {
    final success = await viewModel.login();
    if (!mounted) return; // Guard against async gap
    if (success) {
      GoRouter.of(context).go('/data-sync');
      return;
    }
    final message = viewModel.errorMessage?.trim();
    _showErrorSnackBar(
      message?.isNotEmpty == true ? message! : 'Login failed. Please try again.',
    );
  }

  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A2540), Color(0xFF1A3D8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildGlowEffect(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                          child: Container(
                            width: 360,
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(color: Colors.white.withAlpha(51), width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.lock_outline, color: Colors.white.withAlpha(204), size: 40),
                                const SizedBox(height: 15),
                                const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 3.0,
                                    shadows: [
                                      Shadow(blurRadius: 10.0, color: Colors.black26, offset: Offset(2, 2)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _buildTextField(
                                  context,
                                  label: 'Username',
                                  controller: viewModel.usernameController,
                                  prefixIcon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  context,
                                  label: 'Password',
                                  obscureText: _obscurePassword,
                                  controller: viewModel.passwordController,
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () { /* Forgot Password Logic */ },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                viewModel.loading
                                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                    : _buildSignInButton(viewModel),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 400,
        height: 550,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(102),
              blurRadius: 40.0,
              spreadRadius: 5.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withAlpha(51),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.white.withAlpha(204), width: 2),
        ),
      ),
    );
  }

  Widget _buildSignInButton(LoginViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: const LinearGradient(
          colors: [Colors.lightBlue, Colors.blueAccent, Color(0xFF1A3D8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _login(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: const Text(
          'SIGN IN',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
