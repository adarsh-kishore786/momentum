import 'package:flutter/material.dart';
import 'package:momentum/constants.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Got feedback for me? I would love to hear from you!',
              textAlign: TextAlign.justify,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: cs.primary,
              ),
            ),
            Text(
              'You can contact me in the following ways:',
              textAlign: TextAlign.justify,
              softWrap: true,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: cs.primary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Email me at ${Constants.email}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                ),
                Text(
                  '2. Raise an issue on the repo: ${Constants.repoLink}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: cs.primary,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
