import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:seminarium/navigation/scaffold_with_nested_navigation.dart';
import 'package:seminarium/features/account/account.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/features/account/edit_profile_page.dart';
import 'package:seminarium/features/chat/chat_page.dart';
import 'package:seminarium/features/login_page.dart';
import 'package:seminarium/features/chat/messages.dart';
import 'package:seminarium/features/plans/plans.dart';
import 'package:seminarium/features/plans/plans_day.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:seminarium/features/landing_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorAKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellA');
final GlobalKey<NavigatorState> _shellNavigatorBKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellB');
final GlobalKey<NavigatorState> _shellNavigatorCKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellC');
final GlobalKey<NavigatorState> _shellNavigatorDKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellD');
final GlobalKey<NavigatorState> _shellNavigatorLoginKey =
    GlobalKey<NavigatorState>(debugLabel: 'login');
  
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  usePathUrlStrategy();
  runApp(
    ProviderScope(child: const MyApp()),
  );
}

final goRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(
          navigationShell: navigationShell,
          numberOfBranches: 4,
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => MaterialPage(
                child: LandingPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            GoRoute(
              path: '/plans',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: Plans(),
              ),
              routes: [
                GoRoute(
                  path: 'day/:day',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final day = int.parse(state.pathParameters['day']!);
                    return PlansDay(
                      day: day,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/messages',
              pageBuilder: (context, state) => NoTransitionPage(
                child: Messages(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'chat/:id/:email',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: ChatPage(
                      receiverUserEmail: state.pathParameters['email']!,
                      receiverUserID: state.pathParameters['id']!,
                      chatId: state.pathParameters['id']!,
                      hideNavigationBar: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDKey,
          routes: [
            GoRoute(
                path: '/account',
                pageBuilder: (context, state) => const NoTransitionPage(
                      child: Account(),
                    ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: EditProfilePage(),
                    ),
                  ),
                ]),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLoginKey,
          routes: [
            GoRoute(
              path: '/login',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LoginPage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerConfig: goRouter,
    );
  }
}
