import 'package:dip_app_2/components/my_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", 
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation:  0,
      ),
      drawer: const MyDrawer(),
    );
  }
}