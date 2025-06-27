import 'package:flutter/material.dart';

class LivesCounter extends StatelessWidget {
  const LivesCounter(this.remainingAttemps, {super.key});

  final int remainingAttemps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Intentos'),
        const SizedBox(
          height: 4,
        ),
        Text('$remainingAttemps'),
      ],
    );
  }
}
