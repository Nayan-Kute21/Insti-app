import 'package:flutter/material.dart';

class BusSchedulePage extends StatelessWidget {
  const BusSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(239, 243, 250, 1),
        toolbarHeight: 70,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Bus Schedule 🚌',
          style: TextStyle(
            color: Color.fromRGBO(19, 46, 158, 1),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildScheduleCard(
            'Main Gate to Academic Area',
            [
              {'time': '8:30 AM', 'days': 'Monday - Friday'},
              {'time': '9:30 AM', 'days': 'Monday - Friday'},
              {'time': '10:30 AM', 'days': 'Monday - Friday'},
              {'time': '12:30 PM', 'days': 'Monday - Friday'},
              {'time': '4:30 PM', 'days': 'Monday - Friday'},
            ],
          ),
          const SizedBox(height: 16),
          _buildScheduleCard(
            'Academic Area to Hostels',
            [
              {'time': '1:00 PM', 'days': 'Monday - Friday'},
              {'time': '5:00 PM', 'days': 'Monday - Friday'},
              {'time': '6:30 PM', 'days': 'Monday - Friday'},
              {'time': '8:30 PM', 'days': 'Monday - Friday'},
              {'time': '9:30 PM', 'days': 'Monday - Friday'},
            ],
          ),
          const SizedBox(height: 16),
          _buildScheduleCard(
            'Weekend Schedule',
            [
              {'time': '9:00 AM', 'days': 'Saturday & Sunday'},
              {'time': '12:00 PM', 'days': 'Saturday & Sunday'},
              {'time': '3:00 PM', 'days': 'Saturday & Sunday'},
              {'time': '6:00 PM', 'days': 'Saturday & Sunday'},
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Bus schedule is subject to change during holidays and special events',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '• Please be at the bus stop 5 minutes before the scheduled time',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '• For any queries, contact the transport office at 123-456-7890',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String title, List<Map<String, String>> schedules) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(52, 57, 77, 1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: schedules.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          schedules[index]['time']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      schedules[index]['days']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
