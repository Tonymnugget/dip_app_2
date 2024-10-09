import 'package:dip_app_2/components/my_button.dart';
import 'package:dip_app_2/components/my_textfield.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {

  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  SignupPage({super.key, required this.onTap});

  // register method 
  void register(BuildContext context) {
    // get auth service
    final authService = AuthService();

    try {
      authService.signup(
        _usernameController.text, 
        _emailController.text, 
        _passwordController.text,
      );
    } catch (e) {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              
              const SizedBox(height: 25),
              
              // app name
              const Text(
                "A P P N A M E",
                style:TextStyle(fontSize: 20),
              ),
              
              const SizedBox(height: 50),
          
              // username textfield
              MyTextField(
                hintText: "Username", 
                obscureText: false, 
                controller: _usernameController,
              ),

              const SizedBox(height: 10),
              // email textfield
              MyTextField(
                hintText: "Email username@e.ntu.edu.sg", 
                obscureText: false, 
                controller: _emailController,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                hintText: "Password", 
                obscureText: true, 
                controller: _passwordController,
              ),

              const SizedBox(height: 25),

              // sign up button 
              MyButton(
                text: "Sign up",
                onTap: () => register(context),
              ),

              const SizedBox(height: 25),

              // already have an account? sign in here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Sign in Here",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
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