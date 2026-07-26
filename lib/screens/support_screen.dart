import 'package:flutter/material.dart';
import 'package:momentum/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Support me')),
      body: Padding(
        padding: EdgeInsets.all(6),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                '''
                If you feel that Momentum brought some value to you, please
                consider donating. Any amount helps!
                '''.replaceAll(RegExp(r'\s{2,}'), ' '),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 20
                ),
              ),
              Image.asset(
                'assets/qr.jpeg',
                width: 150,
              ),
              Text(
                'For UPI users'
              ),
              Text(
                'Alternatively, you can',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 20
                ),
              ),
              CoffeeButton(),
              Text(
                '''
                Money is not the only way to help. You can also help me in
                maintaining the codebase by submitting a PR to the repo
                at ${Constants.repoLink}
                '''.replaceAll(RegExp(r'\s{2,}'), ' '),
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 20
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CoffeeButton extends StatelessWidget {
  final Uri _url = Uri.parse('https://www.buymeacoffee.com/ashketchumx');

  CoffeeButton({super.key});

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _launchUrl,
      icon: const Icon(Icons.coffee),
      label: const Text('Buy Me a Coffee'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFDD00),
        foregroundColor: Colors.black,
      ),
    );
  }
}
