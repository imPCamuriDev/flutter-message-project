import 'package:flutter/material.dart';
import 'conversation_page.dart';
import 'status_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> usuario;
  
  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ConversationPage(usuario: widget.usuario),
      const StatusPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.chat),
                label: Text('Conversas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.circle),
                label: Text('Status'),
              ),
            ],
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
