import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/events.dart';
// import 'screens/map.dart'; // This page is not used in the bottom bar
import 'screens/messMenu.dart';
import 'screens/more.dart';
import 'screens/busSchedule.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // FIX 1: The list of pages now correctly matches the order of the bottom navigation tabs.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    EventsPage(),
    MorePage(),
    BusSchedulePage(), // Correct page for the 'Bus schedule' tab
    MessMenuPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
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
                spreadRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth / 5;
                double indicatorWidth = 56;

                // Calculate position for the indicator
                double indicatorPosition = width * _selectedIndex + (width - indicatorWidth) / 2;

                return Stack(
                  children: [
                    // This is the green selection indicator line
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
                            borderRadius: BorderRadius.circular(2)
                        ),
                      ),
                    ),
                    BottomNavigationBar(
                      // FIX 2: Correct icons and labels to match the pages list
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          activeIcon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.celebration_outlined),
                          activeIcon: Icon(Icons.celebration),
                          label: 'Events',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.dashboard_outlined),
                          activeIcon: Icon(Icons.dashboard),
                          label: 'More',
                        ),
                        BottomNavigationBarItem(
                          // FIX 3: Changed Icons.Bus to a valid icon
                          icon: Icon(Icons.directions_bus_outlined),
                          activeIcon: Icon(Icons.directions_bus),
                          label: 'Bus',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.restaurant_menu_outlined),
                          activeIcon: Icon(Icons.restaurant_menu),
                          label: 'Mess',
                        ),
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey[400],
                      backgroundColor: Colors.transparent,
                      onTap: _onItemTapped,
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
                      selectedFontSize: 12.0,
                      unselectedFontSize: 12.0,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
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