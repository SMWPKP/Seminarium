import 'package:flutter/material.dart';

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Główna')),
              NavigationRailDestination(
                  icon: Icon(Icons.date_range), label: Text('Kalendarz')),
              NavigationRailDestination(
                  icon: Icon(Icons.message), label: Text('Wiadomości')),
              NavigationRailDestination(
                  icon: Icon(Icons.account_circle_sharp), label: Text('Konto')),
            ],
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
