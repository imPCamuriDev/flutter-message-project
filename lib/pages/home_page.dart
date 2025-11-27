import 'package:flutter/material.dart';
import '../components/navigation_rail.dart';
import 'contact_one.dart';
import 'contact_two.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    ContactOne(),
    ContactTwo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRailComp(
            selectedIndex: selectedIndex,
            onSelect: (index) {
              setState(() => selectedIndex = index);
            },
          ),

          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}
