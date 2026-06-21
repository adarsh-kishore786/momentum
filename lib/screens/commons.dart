import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MomentumHeader extends StatelessWidget implements PreferredSizeWidget {
  const MomentumHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        "MOMENTUM",
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MomentumFooter extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MomentumFooter({required this.shell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex
        ),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
