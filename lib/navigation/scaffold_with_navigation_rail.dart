import 'package:flutter/material.dart';

class ScaffoldWithNavigationRail extends StatelessWidget {
  const ScaffoldWithNavigationRail({super.key, required this.body, required this.selectedIndex, required this.onDestinationSelected, this.hideNavigationBar = false,});

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool hideNavigationBar;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if(!hideNavigationBar)
          NavigationRail(selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: const<NavigationRailDestination>[
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Section A')),
            NavigationRailDestination(icon: Icon(Icons.date_range), label: Text('Section B')
            ),
          ],
          ),
          const VerticalDivider(thickness: 1, width: 1,),
          Expanded(child: body),
        ],
      ),
    );
  }
}
