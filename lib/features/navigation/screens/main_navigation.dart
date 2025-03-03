import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../feed/screens/feed_screen.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FeedScreen(),
    EmergencyScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor:
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.video_camera_back_outlined,
              color: _selectedIndex == 1
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
            selectedIcon: Icon(
              Icons.video_camera_back,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.warning_outlined,
              color: _selectedIndex == 2
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
            selectedIcon: Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: 'Emerg',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 3
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
            ),
            selectedIcon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
