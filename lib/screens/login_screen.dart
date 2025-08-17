import 'package:flash_cards/provider/auth_provider.dart';
import 'package:flash_cards/screens/signup_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late TapGestureRecognizer _signUpTapRecognizer;

  @override
  void initState() {
    super.initState();
    _signUpTapRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SignUpScreen()),
            );
          };
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpTapRecognizer.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.toString().trim();
    final password = _passwordController.text.toString().trim();

    await ref.read(authHelperProvider).signIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authStateProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text("Login"),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _signUpTapRecognizer,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              authProvider.isLoading
                  ? CircularProgressIndicator()
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
