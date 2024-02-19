import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/routes/app_route.dart';

class IntroScreenGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      resolver.redirect(const HomepageRoute());
    } else {
      resolver.next(true);
    }
  }
}
