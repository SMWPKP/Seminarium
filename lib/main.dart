import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
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

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorAKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorBKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorCKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorDKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorLoginKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pl', null);

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
                  path: 'day/:year/:month/:day',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final year = int.parse(state.pathParameters['year']!);
                    final month = int.parse(state.pathParameters['month']!);
                    final day = int.parse(state.pathParameters['day']!);
                    final initialDate = DateTime(year, month, day);
                    return PlansDay(
                      initialDate: initialDate,
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
