import 'package:dip_app_2/components/my_button.dart';
import 'package:dip_app_2/components/my_textfield.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTapSignup;
  final void Function()? onTapForgotPassword;

  LoginPage({
    super.key,
    required this.onTapSignup,
    required this.onTapForgotPassword,
  });

  // text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // login method
  void login(BuildContext context) async {
    // auth service
    final authService = AuthService();

    // try login
    try {
      await authService.signin(_emailController.text, _passwordController.text);
    }

    // catch any errors
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Image.asset(
                'assets/images/orbitlogo.png',
                height: 120,
                width: 120,
              ),

              const SizedBox(height: 25),

              // app name
              const Text(
                "O R B I T",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // email textfield
              MyTextField(
                hintText: "Email: username@e.ntu.edu.sg",
                obscureText: false,
                controller: _emailController,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                hintText: "Password:",
                obscureText: true,
                controller: _passwordController,
              ),

              const SizedBox(
                height: 10,
              ),

              // forgot password
              GestureDetector(
                onTap: onTapForgotPassword,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Forgot Password"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                text: "Sign in",
                onTap: () => login(context),
              ),

              const SizedBox(height: 25),

              // don't have an account? register here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  GestureDetector(
                    onTap: onTapSignup,
                    child: Text(
                      " Register Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
