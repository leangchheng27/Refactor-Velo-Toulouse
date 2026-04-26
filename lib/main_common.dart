import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/map/map_screen.dart';
import 'ui/screens/plan/plan_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/states/booking_state.dart';
import 'ui/states/subscription_state.dart';

void mainCommon(List<InheritedProvider> providers) {
  runApp(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(nextScreen: MyApp()),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 1;
  static const String _currentUserId = 'currentUserId';

  static const List<Widget> _pages = [
    ProfileScreen(),
    MapScreen(),
    PlanScreen(),
  ];

  void _setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    final subscriptionState = context.read<SubscriptionState>();
    final bookingState = context.read<BookingState>();
    
    // Load subscription and booking data on app start
    await Future.wait([
      subscriptionState.loadActiveSubscription(_currentUserId),
      bookingState.loadActiveBooking(_currentUserId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFFF7A1A);
    const inactiveColor = Color(0xFF9AA0A6);
    final bookingState = context.watch<BookingState>();
    final hasCurrentRide = bookingState.hasCurrentRide;
    final shouldHideBottomNav = _currentIndex == 1 && hasCurrentRide;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: shouldHideBottomNav
          ? null
          : Material(
        color: Colors.white,
        elevation: 12,
        child: SizedBox(
          height: 98,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 22,
              right: 22,
              top: 12,
              bottom: 10,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _TabItem(
                        icon: Icons.directions_bike_outlined,
                        label: 'MY PASS',
                        isSelected: _currentIndex == 0,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => _setIndex(0),
                      ),
                    ),
                    const SizedBox(width: 84),
                    Expanded(
                      child: _TabItem(
                        icon: Icons.local_offer_outlined,
                        label: 'SUBSCRIPTION',
                        isSelected: _currentIndex == 2,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => _setIndex(2),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -30,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _setIndex(1),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF8A00), Color(0xFFD92B74)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, color: Colors.white, size: 28),
                            SizedBox(height: 2),
                            Text(
                              'MAP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}