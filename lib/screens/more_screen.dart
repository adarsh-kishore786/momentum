import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {

  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            padding: const EdgeInsets.all(10.0),
            childAspectRatio: 1.0,
            shrinkWrap: true,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                ),
                onPressed: () {},
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_backup_restore),
                    Text('Backup')
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                ),
                onPressed: () {},
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feedback),
                    Text('Feedback')
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                ),
                onPressed: () {},
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info),
                    Text('About')
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                ),
                onPressed: () {},
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite),
                    Text('Support me')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
