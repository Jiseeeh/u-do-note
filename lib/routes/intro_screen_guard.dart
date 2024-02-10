import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IntroScreenGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // TODO: redirect to home
    } else {
      resolver.next(true);
    }
  }
}
