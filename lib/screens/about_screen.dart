import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = 
        '''
        Personal learning projects do not stall because of lost interest, but because
        there's no lightweight way to notice neglect, record progress, or capture 
        ideas as they come. Traditional task managers impose a completion mindset 
        that doesn't fit open-ended technical work.
        <br>
        Which is why I created Momentum, a project tracker that does not make 
        you tick a checklist of projects, but instead lets you log sessions to
        measure progress and see how much time and effort you are spending on 
        your projects. You can also note down your project milestones and ideas
        as and when they come to you.
        <br>
        I hope you find this useful.
        ''';

    return Scaffold(
      appBar: AppBar(title: const Text('About Momentum')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            text.replaceAll(RegExp(r'\s{2,}'), ' ').replaceAll('<br>', '\n\n'),
            textAlign: TextAlign.justify,
            softWrap: true,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      )
    );
  }
}
