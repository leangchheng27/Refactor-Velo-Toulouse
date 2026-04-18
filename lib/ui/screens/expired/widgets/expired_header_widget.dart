import 'package:flutter/material.dart';

class ExpiredHeaderWidget extends StatelessWidget {
  final String bikeId;
  final String? stationName;

  const ExpiredHeaderWidget({
    super.key,
    required this.bikeId,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'What would you like to do next?',
          style: TextStyle(
            fontSize: 33,
            height: 1.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A2D43),
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'Bike #$bikeId is still available at ',
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF7C6474),
            ),
            children: [
              TextSpan(
                text: stationName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A2D43),
                ),
              ),
              const TextSpan(text: '. No charge was made.'),
            ],
          ),
        ),
      ],
    );
  }
}
