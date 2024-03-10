// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_route.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    HomepageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomepageScreen(),
      );
    },
    IntroRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const IntroScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    NoteTakingRoute.name: (routeData) {
      final args = routeData.argsAs<NoteTakingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: NoteTakingScreen(
          notebookId: args.notebookId,
          note: args.note,
          key: args.key,
        ),
      );
    },
    NotebookPagesRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<NotebookPagesRouteArgs>(
          orElse: () => NotebookPagesRouteArgs(
              notebookId: pathParams.getString('notebookId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: NotebookPagesScreen(
          args.notebookId,
          key: args.key,
        ),
      );
    },
    NotebooksRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotebooksScreen(),
      );
    },
    ReviewRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ReviewScreen(),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpScreen(),
      );
    },
  };
}

/// generated route for
/// [HomepageScreen]
class HomepageRoute extends PageRouteInfo<void> {
  const HomepageRoute({List<PageRouteInfo>? children})
      : super(
          HomepageRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomepageRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [IntroScreen]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
      : super(
          IntroRoute.name,
          initialChildren: children,
        );

  static const String name = 'IntroRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NoteTakingScreen]
class NoteTakingRoute extends PageRouteInfo<NoteTakingRouteArgs> {
  NoteTakingRoute({
    required String notebookId,
    required NoteEntity note,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          NoteTakingRoute.name,
          args: NoteTakingRouteArgs(
            notebookId: notebookId,
            note: note,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'NoteTakingRoute';

  static const PageInfo<NoteTakingRouteArgs> page =
      PageInfo<NoteTakingRouteArgs>(name);
}

class NoteTakingRouteArgs {
  const NoteTakingRouteArgs({
    required this.notebookId,
    required this.note,
    this.key,
  });

  final String notebookId;

  final NoteEntity note;

  final Key? key;

  @override
  String toString() {
    return 'NoteTakingRouteArgs{notebookId: $notebookId, note: $note, key: $key}';
  }
}

/// generated route for
/// [NotebookPagesScreen]
class NotebookPagesRoute extends PageRouteInfo<NotebookPagesRouteArgs> {
  NotebookPagesRoute({
    required String notebookId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          NotebookPagesRoute.name,
          args: NotebookPagesRouteArgs(
            notebookId: notebookId,
            key: key,
          ),
          rawPathParams: {'notebookId': notebookId},
          initialChildren: children,
        );

  static const String name = 'NotebookPagesRoute';

  static const PageInfo<NotebookPagesRouteArgs> page =
      PageInfo<NotebookPagesRouteArgs>(name);
}

class NotebookPagesRouteArgs {
  const NotebookPagesRouteArgs({
    required this.notebookId,
    this.key,
  });

  final String notebookId;

  final Key? key;

  @override
  String toString() {
    return 'NotebookPagesRouteArgs{notebookId: $notebookId, key: $key}';
  }
}

/// generated route for
/// [NotebooksScreen]
class NotebooksRoute extends PageRouteInfo<void> {
  const NotebooksRoute({List<PageRouteInfo>? children})
      : super(
          NotebooksRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotebooksRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReviewScreen]
class ReviewRoute extends PageRouteInfo<void> {
  const ReviewRoute({List<PageRouteInfo>? children})
      : super(
          ReviewRoute.name,
          initialChildren: children,
        );

  static const String name = 'ReviewRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
