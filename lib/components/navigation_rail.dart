import 'package:flutter/material.dart';

class NavigationRailComp extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const NavigationRailComp({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect, // Callback ao selecionar um item do menu lateral
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.chat_outlined), // Ícone quando não está selecionado
          selectedIcon: Icon(Icons.chat_rounded), // Ícone quando está selecionado
          label: Text("Home"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text("Status"),
        ),
      ],
    );
  }
}
