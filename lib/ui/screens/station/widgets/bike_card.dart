import 'package:flutter/material.dart';
import '../../../../model/bike/bike.dart';

class BikeCardWidget extends StatelessWidget {
  final Bike bike;
  final VoidCallback onBook;

  const BikeCardWidget({super.key, required this.bike, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isAvailable = bike.status == BikeStatus.available;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'SLOTS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isAvailable ? Colors.black54 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAvailable
                      ? const LinearGradient(
                          colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade400,
                            Colors.grey.shade400,
                          ],
                        ),
                ),
                child: Text(
                  '${bike.slotNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 54,
            color: isAvailable ? const Color(0xFFD7D7D7) : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bike #${bike.id}',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: isAvailable ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.directions_bike,
                  size: 26,
                  color: isAvailable
                      ? const Color(0xFFD63B58)
                      : Colors.grey.shade500,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: isAvailable ? const Color(0xFFD63B58) : Colors.grey,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (isAvailable ? const Color(0xFFD63B58) : Colors.grey)
                      .withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 34,
              width: 85,
              child: TextButton(
                onPressed: isAvailable ? onBook : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  bike.status == BikeStatus.available ? 'Book' : 'Booked',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}