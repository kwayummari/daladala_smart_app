import 'package:flutter/material.dart';

class BusinessBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BusinessBottomNav({
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.approval), label: 'Approvals'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Profile'),
      ],
    );
  }
}
