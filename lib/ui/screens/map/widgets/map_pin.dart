import 'package:flutter/material.dart';

class MapPinWidget extends StatelessWidget {
  final bool isSelected;
  final int availableBikeCount;
  final String countPrefix;
  final Color pinColor;
  final VoidCallback onTap;

  const MapPinWidget({
    super.key,
    this.isSelected = false,
    this.availableBikeCount = 0,
    this.countPrefix = '',
    this.pinColor = Colors.red,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pinSize = isSelected ? 80.0 : 40.0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Icon(
            Icons.location_pin,
            color: pinColor,
            size: pinSize,
          ),
          Positioned(
            top: isSelected ? 6 : 2,
            child: Container(
              constraints: BoxConstraints(
                minWidth: isSelected ? 32 : 24,
                minHeight: isSelected ? 32 : 24,
              ),
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: pinColor,
                  width: isSelected ? 2 : 1.2,
                ),
              ),
              child: Text(
                '$countPrefix$availableBikeCount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSelected ? 18 : 14,
                  fontWeight: FontWeight.w800,
                  color: pinColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}