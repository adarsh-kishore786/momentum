import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momentum/screens/dashboard_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: DashboardScreen()
      )
    )
  );
}
