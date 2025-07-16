import 'package:flutter/material.dart';

class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key});

  @override
  _BusSchedulePageState createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  bool isWeekdays = true;

  // Show report issue dialog
  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Bus Issue'),
          content: const Text('Please report any bus issues to transport@iitj.ac.in'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
          'Bus Schedule',
          style: TextStyle(
            color: Color.fromRGBO(19, 46, 158, 1),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showReportIssueDialog,
            child: const Text(
              'Report bus issue',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Container(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tabItem('MON - FRI', selected: isWeekdays),
                    const SizedBox(width: 16),
                    _tabItem('SAT - SUN', selected: !isWeekdays),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionBlock(
                  title: 'Leave to city',
                  from: 'IITJ Campus',
                  to: 'MBM College',
                  times: isWeekdays ? _getWeekdaysToCitySchedule() : _getWeekendToCitySchedule(),
                  highlightIndex: _getCurrentBusIndex(isWeekdays ? _getWeekdaysToCitySchedule() : _getWeekendToCitySchedule()),
                ),
                const SizedBox(height: 24),
                _sectionBlock(
                  title: 'Return to campus',
                  from: 'MBM College',
                  to: 'IITJ Campus',
                  times: isWeekdays ? _getWeekdaysReturnSchedule() : _getWeekendReturnSchedule(),
                  highlightIndex: _getCurrentBusIndex(isWeekdays ? _getWeekdaysReturnSchedule() : _getWeekendReturnSchedule()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TimeRange> _getWeekdaysToCitySchedule() {
    return [
      TimeRange('07:30 AM', '08:30 AM'),
      TimeRange('04:30 PM', '05:30 PM', leavesInMin: _calculateLeavesInMin('04:30 PM')),
      TimeRange('09:00 PM', '10:00 PM'),
    ];
  }

  List<TimeRange> _getWeekendToCitySchedule() {
    return [
      TimeRange('09:00 AM', '10:00 AM'),
      TimeRange('02:00 PM', '03:00 PM'),
      TimeRange('07:00 PM', '08:00 PM'),
    ];
  }

  List<TimeRange> _getWeekdaysReturnSchedule() {
    return [
      TimeRange('09:00 AM', '10:00 AM'),
      TimeRange('06:00 PM', '07:00 PM', leavesInMin: _calculateLeavesInMin('06:00 PM')),
      TimeRange('10:30 PM', '11:30 PM'),
    ];
  }

  List<TimeRange> _getWeekendReturnSchedule() {
    return [
      TimeRange('10:30 AM', '11:30 AM'),
      TimeRange('03:30 PM', '04:30 PM'),
      TimeRange('08:30 PM', '09:30 PM'),
    ];
  }

  int? _calculateLeavesInMin(String timeString) {
    final now = TimeOfDay.now();
    final timeParts = timeString.split(' ');
    final hourMin = timeParts[0].split(':');
    final hour = int.parse(hourMin[0]);
    final minute = int.parse(hourMin[1]);
    final isAM = timeParts[1] == 'AM';
    
    final scheduledHour = isAM ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12);
    final scheduledTime = TimeOfDay(hour: scheduledHour, minute: minute);
    
    final nowInMinutes = now.hour * 60 + now.minute;
    final scheduledInMinutes = scheduledTime.hour * 60 + scheduledTime.minute;
    
    final diff = scheduledInMinutes - nowInMinutes;
    return diff > 0 && diff <= 120 ? diff : null; // Show only if within next 2 hours
  }

  int _getCurrentBusIndex(List<TimeRange> schedules) {
    for (int i = 0; i < schedules.length; i++) {
      if (schedules[i].leavesInMin != null) {
        return i;
      }
    }
    return -1;
  }

  Widget _tabItem(String text, {required bool selected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isWeekdays = text == 'MON - FRI';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: selected ? const Border(
            bottom: BorderSide(color: Colors.green, width: 3),
          ) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _sectionBlock({
    required String title,
    required String from,
    required String to,
    required List<TimeRange> times,
    required int highlightIndex,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with route
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAFD),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromRGBO(19, 46, 158, 1),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.school, size: 22, color: Color.fromRGBO(19, 46, 158, 1)),
                              const SizedBox(height: 2),
                              Text(
                                from,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(19, 46, 158, 1),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_forward, size: 16, color: Color.fromRGBO(19, 46, 158, 1)),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Icon(Icons.location_city, size: 22, color: Color.fromRGBO(19, 46, 158, 1)),
                              const SizedBox(height: 2),
                              Text(
                                to,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(19, 46, 158, 1),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(times.length, (index) {
          final time = times[index];
          final isActive = index == highlightIndex;
          return _busCard(time, isActive);
        }),
      ],
    );
  }

  Widget _busCard(TimeRange time, bool isActive) {
    final borderColor = isActive
        ? const Color(0xFF357BFE)
        : const Color(0xFFE0E0E0);

    final sideColor = time.leavesInMin != null
        ? (time.leavesInMin! <= 15
            ? const Color(0xFFF55142)
            : time.leavesInMin! <= 30
                ? const Color(0xFFFF9900)
                : const Color(0xFF357BFE))
        : null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isActive ? 10 : 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15), 
                  blurRadius: 8, 
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          if (isActive && sideColor != null)
            Container(
              width: 6,
              height: 70,
              decoration: BoxDecoration(
                color: sideColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          Expanded(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: isActive ? 20 : 14, 
                vertical: isActive ? 12 : 6,
              ),
              title: Row(
                children: [
                  Text(
                    time.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isActive ? 18 : 14,
                      color: isActive ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isActive ? '━━━━━━' : '━━━', 
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isActive ? 16 : 12,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time.end,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: isActive ? 16 : 13,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _busTag('B2', isActive: isActive),
                ],
              ),
              subtitle: isActive && time.leavesInMin != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Leaves in ${time.leavesInMin} min',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _busTag(String tag, {bool isActive = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 12 : 8, 
        vertical: isActive ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF357BFE) : const Color(0xFFEDF0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isActive ? 14 : 11,
          color: isActive ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class TimeRange {
  final String start;
  final String end;
  final int? leavesInMin;

  TimeRange(this.start, this.end, {this.leavesInMin});
}
