import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup and Restore'),
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () {},
            child: ListTile(
              title: const Text('Export as sqlite DB'),
            )
          ),
          GestureDetector(
            onTap: () {},
            child: ListTile(
              title: const Text('Import from sqlite DB'),
            )
          )
        ],
      )
    );
  }
}
