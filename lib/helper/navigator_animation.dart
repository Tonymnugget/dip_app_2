import 'package:flutter/material.dart';

class CustomNavigator {
  /// Navigates to the specified [page] with a right-to-left slide transition.
  static Route createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration:
          const Duration(milliseconds: 300), // Adjust duration as needed
    );
  }

  /// Replaces the current page with the specified [page] with no transition animation.
  static void navigateWithNoAnimation(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero, // No animation
        reverseTransitionDuration: Duration.zero, // No reverse animation
      ),
      (route) => false, // this clears all previous routes
    );
  }

  static void navigateWithNoAnimationWithBack(
      BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero, // No animation
        reverseTransitionDuration: Duration.zero, // No reverse animation
      ),
    );
  }

  /// Navigates to the specified [page] with a right-to-left slide transition and replaces the current page.
  static void navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      createSlideRoute(page),
    );
  }
}
