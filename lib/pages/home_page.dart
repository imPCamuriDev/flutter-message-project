import 'package:flutter/material.dart';
import 'conversation_page.dart';
import 'status_page.dart';
import "../usuarios/models/usuario.dart";

class HomePage extends StatefulWidget {
  final Usuario usuario; // Agora é Usuario, não Map<String, dynamic>
  
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ConversationPage(usuario: widget.usuario), // Já é do tipo Usuario
      const StatusPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Conversas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.circle_outlined),
                selectedIcon: Icon(Icons.circle),
                label: Text('Status'),
              ),
            ],
          ),

          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),
          
          // Pages
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}