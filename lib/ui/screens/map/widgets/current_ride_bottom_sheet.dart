import 'dart:async';

import 'package:flutter/material.dart';

class CurrentRideBottomSheet extends StatefulWidget {
  const CurrentRideBottomSheet({
    super.key,
    required this.stationName,
    required this.slotNumber,
    required this.rideStartTime,
    required this.onStartReturnSelection,
    this.isSelectingReturnStation = false,
    this.isReturning = false,
  });

  final String stationName;
  final int? slotNumber;
  final DateTime rideStartTime;
  final Future<void> Function() onStartReturnSelection;
  final bool isSelectingReturnStation;
  final bool isReturning;

  @override
  State<CurrentRideBottomSheet> createState() => _CurrentRideBottomSheetState();
}

class _CurrentRideBottomSheetState extends State<CurrentRideBottomSheet> {
  late Timer _timer;
  late Duration _elapsed;
  late bool _isSelectingReturnStation;

  @override
  void initState() {
    super.initState();
    _isSelectingReturnStation = widget.isSelectingReturnStation;
    _elapsed = _computeElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed = _computeElapsed();
      });
    });
  }

  @override
  void didUpdateWidget(covariant CurrentRideBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelectingReturnStation != widget.isSelectingReturnStation) {
      _isSelectingReturnStation = widget.isSelectingReturnStation;
    }
    if (oldWidget.rideStartTime != widget.rideStartTime) {
      setState(() {
        _elapsed = _computeElapsed();
      });
    }
  }

  Duration _computeElapsed() {
    final diff = DateTime.now().difference(widget.rideStartTime);
    if (diff.isNegative) {
      return Duration.zero;
    }
    return diff;
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotText = widget.slotNumber != null
        ? 'Slot ${widget.slotNumber.toString().padLeft(2, '0')}'
        : 'Slot -';

    return GestureDetector(
      // Keep sheet taps from bubbling to the map behind it.
      onTap: () {},
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Current ride',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F5EA),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '• Active',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isSelectingReturnStation) ...[
                const Divider(height: 1),
                const SizedBox(height: 18),
                const Text(
                  'Select a station to return your bike',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
              ] else ...[
                const Divider(height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'Station',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        widget.stationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Slot',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      slotText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Riding for',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatElapsed(_elapsed),
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: widget.isReturning
                          ? null
                          : () async {
                              setState(() {
                                _isSelectingReturnStation = true;
                              });
                              await widget.onStartReturnSelection();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        widget.isReturning ? 'Returning...' : 'Return Bike',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}