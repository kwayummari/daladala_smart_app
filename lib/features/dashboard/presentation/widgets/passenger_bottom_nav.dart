import 'package:flutter/material.dart';

class PassengerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PassengerBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'My Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Pre-book',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'On-demand',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}