import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/navigation/scaffold_with_navigation_bar.dart';
import 'package:seminarium/navigation/scaffold_with_navigation_rail.dart';
import 'package:seminarium/screens/login_page.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
    required this.numberOfBranches,
    this.hideNavigationBar = false,
  }) : super(
            key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;
  final int numberOfBranches;
  final bool hideNavigationBar;

  void _goBranch(int index) {
    print('Trying to navigate to branch index: $index');
    if (index >= 0 && index < numberOfBranches) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    } else {
      print('Error: Index out of range');
      throw ArgumentError('Index out of range');
    }
  }

  Widget build(BuildContext context) {
  return LayoutBuilder(builder: (context, constraints) {
    if (FirebaseAuth.instance.currentUser != null) {
       if (constraints.maxWidth < 450) {
        return ScaffoldWithNavigationBar(
            body: navigationShell,
            selectedIndex: navigationShell.currentIndex,
            hideNavigationBar: hideNavigationBar, 
            onDestinationSelected: (index) => _goBranch(index),
                            );
      } else {
        return ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          hideNavigationBar: hideNavigationBar,
          onDestinationSelected: (index) => _goBranch(index),
        );
      }
    } else {
      return LoginPage();
    }
  });
}
}