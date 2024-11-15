import 'package:dip_app_2/screens/user_authentication/forgot_password.dart';
import 'package:dip_app_2/screens/user_authentication/login.dart';
import 'package:dip_app_2/screens/user_authentication/signup.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Initially, show login page
  bool showLoginPage = true;
  bool showSignupPage = false;
  bool showForgotPasswordPage = false;

  // Method to toggle between pages
  void toggleToSignupPage() {
    setState(() {
      showLoginPage = false;
      showSignupPage = true;
      showForgotPasswordPage = false;
    });
  }

  void toggleToLoginPage() {
    setState(() {
      showLoginPage = true;
      showSignupPage = false;
      showForgotPasswordPage = false;
    });
  }

  void toggleToForgotPasswordPage() {
    setState(() {
      showLoginPage = false;
      showSignupPage = false;
      showForgotPasswordPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTapSignup: toggleToSignupPage,
        onTapForgotPassword: toggleToForgotPasswordPage,
      );
    } else if (showSignupPage) {
      return SignupPage(
        onTap: toggleToLoginPage,
      );
    } else {
      return ForgotPasswordPage(
        onTap: toggleToLoginPage,
      );
    }
  }
}
