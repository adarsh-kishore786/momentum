import 'package:flutter/material.dart';

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
