import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatelessWidget {
  final int countdown;

  const CountdownTimerWidget({
    super.key,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 148,
              height: 148,
              child: CircularProgressIndicator(
                value: countdown / 30,
                strokeWidth: 6,
                backgroundColor: const Color(0xFFF1D7B5),
                color: const Color(0xFFFF9800),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 116,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$countdown',
                        style: const TextStyle(
                          fontSize: 44,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E2730),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SECONDS TO UNLOCK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          height: 1,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8A7682),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Tap the button below to release the lock on the bike.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF8A7682),
            ),
          ),
        ),
      ],
    );
  }
}
