import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/events.dart';
import 'screens/map.dart';
import 'screens/messMenu.dart';
import 'screens/more.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    EventsPage(),
    MorePage(), // Use MorePage instead of placeholder
    MapPage(),
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
                
                // Calculate position with proper constraints
                double indicatorPosition = width * _selectedIndex + (width - indicatorWidth) / 2;
                
                // Keep indicator within bounds with better calculation
                if (_selectedIndex == 0) {
                  indicatorPosition = (width - indicatorWidth) / 2 + 4;
                } else if (_selectedIndex == 4) {
                  indicatorPosition = constraints.maxWidth - width + (width - indicatorWidth) / 2 - 4;
                }
                
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: indicatorPosition,
                      child: Container(
                        height: 4,
                        width: indicatorWidth,
                        color: const Color.fromRGBO(162, 233, 89, 1),
                      ),
                    ),
                    BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.celebration),
                          label: 'Events',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.keyboard_double_arrow_up),
                          label: 'More',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.map),
                          label: 'Map',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.restaurant),
                          label: 'Mess',
                        ),
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey,
                      backgroundColor: Colors.transparent,
                      onTap: _onItemTapped,
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
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
