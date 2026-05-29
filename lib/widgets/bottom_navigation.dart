import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavigation({super.key, required this.currentIndex});

  static const List<String> _routes = ['/home', '/live', '/violations', '/score'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_routes[i]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),    activeIcon: Icon(Icons.home),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.speed_outlined),   activeIcon: Icon(Icons.speed),       label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_outlined), activeIcon: Icon(Icons.warning),     label: 'Violations'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),activeIcon: Icon(Icons.bar_chart),  label: 'Score'),
        ],
      ),
    );
  }
}
