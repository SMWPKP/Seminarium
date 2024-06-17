import 'package:flutter/material.dart';

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0x00ffffff),
        elevation: 0,
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Główna'),
          NavigationDestination(
              icon: Icon(Icons.date_range), label: 'Kalendarz'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Wiadomości'),
          NavigationDestination(
              icon: Icon(Icons.account_circle_sharp), label: 'Konto'),
        ],
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
