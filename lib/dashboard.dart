import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/events.dart';
import 'screens/map.dart';
import 'screens/messMenu.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    EventsPage(),
    Text('More'), // Placeholder for "More" section
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        width: 380,
        height: 57,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(52, 57, 77, 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth / 5;
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: width * _selectedIndex + (width - 56) / 2,
                  child: Container(
                    height: 4,
                    width: 56,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
