import 'package:flutter/material.dart';
import 'screens/auth_wrapper.dart'; // 1. Import this to get the UserRole enum
import 'screens/home.dart';
import 'screens/events.dart';
import 'screens/messMenu.dart';
import 'screens/more_tab_navigator.dart';
import 'screens/busSchedule.dart';

class DashboardPage extends StatefulWidget {
  // 2. Accept the UserRole from the AuthWrapper
  final UserRole userRole;
  const DashboardPage({super.key, required this.userRole});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 3. Start on the 'Home' tab (index 0) as it's always available
  int _selectedIndex = 0;

  // These lists will be built based on the user's role
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navBarItems;

  @override
  void initState() {
    super.initState();

    // 4. Conditionally build the page list and nav items
    if (widget.userRole == UserRole.authenticated) {
      // User is logged in, show all 5 tabs
      _pages = const [
        HomePage(),
        EventsAndClubsScreen(),
        MoreTabNavigator(),
        BusSchedulePage(),
        MessMenuPage(),
      ];
      _navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.celebration_outlined), activeIcon: Icon(Icons.celebration), label: 'Events'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'More'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_bus_outlined), activeIcon: Icon(Icons.directions_bus), label: 'Bus'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Mess'),
      ];
    } else {
      // User is a guest, show only 3 tabs
      _pages = const [
        HomePage(),
        BusSchedulePage(),
        MessMenuPage(),
      ];
      _navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_bus_outlined), activeIcon: Icon(Icons.directions_bus), label: 'Bus'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Mess'),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages, // Use the dynamically built page list
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(52, 57, 77, 1),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 5. Make the width calculation dynamic based on the number of items
                double width = constraints.maxWidth / _navBarItems.length;
                double indicatorWidth = 56;
                double indicatorPosition = width * _selectedIndex + (width - indicatorWidth) / 2;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      top: 0,
                      left: indicatorPosition,
                      child: Container(
                        height: 4,
                        width: indicatorWidth,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(162, 233, 89, 1),
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    BottomNavigationBar(
                      items: _navBarItems, // Use the dynamically built item list
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey[400],
                      backgroundColor: Colors.transparent,
                      onTap: _onItemTapped,
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
                      selectedFontSize: 12.0,
                      unselectedFontSize: 12.0,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}