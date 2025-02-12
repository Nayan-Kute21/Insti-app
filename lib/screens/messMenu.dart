import 'package:flutter/material.dart';

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({super.key});

  @override
  _MessMenuPageState createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: DateTime.now().weekday - 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 250, 1), // Same as the TabBar background color
      appBar: AppBar(
        title: const Text('Mess Menu 👩‍🍳'),
        backgroundColor: const Color.fromRGBO(239, 243, 250, 1), // Same as the TabBar background color
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(53),
          child: Column(
            children: [
              Container(
                height: 1,
                color: Colors.grey,
              ),
              Container(
                width: 412,
                height: 53,
                padding: const EdgeInsets.symmetric(horizontal: 10), // Adjusted padding
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(239, 243, 250, 1), // TabBar background color
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromRGBO(162, 233, 89, 1),
                        width: 4,
                      ),
                    ),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(text: 'MONDAY'),
                    Tab(text: 'TUESDAY'),
                    Tab(text: 'WEDNESDAY'),
                    Tab(text: 'THURSDAY'),
                    Tab(text: 'FRIDAY'),
                    Tab(text: 'SATURDAY'),
                    Tab(text: 'SUNDAY'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDayMenu('Monday'),
          _buildDayMenu('Tuesday'),
          _buildDayMenu('Wednesday'),
          _buildDayMenu('Thursday'),
          _buildDayMenu('Friday'),
          _buildDayMenu('Saturday'),
          _buildDayMenu('Sunday'),
        ],
      ),
    );
  }

  Widget _buildDayMenu(String day) {
    return Center(
      child: Text('Menu for $day'),
    );
  }
}