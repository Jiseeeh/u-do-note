import 'package:auto_route/auto_route.dart';
import 'package:u_do_note/features/authentication/presentation/pages/intro_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/login_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/sign_up_screen.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // add routes here
        AutoRoute(page: IntroRoute.page, path: '/intro', initial: true),
        AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
        AutoRoute(page: LoginRoute.page, path: '/login')
      ];
}
