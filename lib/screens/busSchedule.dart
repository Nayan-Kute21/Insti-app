import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import your models and services
import '../services/bus_api_service.dart';
import '../models/bus.dart';

// ===================================================================
// WIDGET
// ===================================================================
class BusSchedulePage extends StatefulWidget {
  const BusSchedulePage({super.key});

  @override
  State<BusSchedulePage> createState() => _BusSchedulePageState();
}

class _BusSchedulePageState extends State<BusSchedulePage> {
  final BusApiService _apiService = BusApiService();
  late Future<List<BusSchedule>> _schedulesFuture;
  bool isMonToSat = true; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _apiService.fetchAllSchedules();
    int today = DateTime.now().weekday;
    // FIX: Logic now treats Monday to Saturday as the first category
    isMonToSat = today >= DateTime.monday && today <= DateTime.saturday;
  }

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
        color: Color(0xFF132E9E),
        fontSize: 20,
        fontFamily: 'Bricolage Grotesque',
        fontWeight: FontWeight.w600);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FA),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFEFF3FA),
        title: Row(
          children: [
            const Text('Bus Schedule', style: headerStyle),
            const SizedBox(width: 4),
            const Text('🚌', style: TextStyle(fontSize: 24)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Report Bus Issue',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Column(
            children: [
              const Divider(color: Color(0xFFB4B7C2), height: 1),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // FIX: Changed tab labels
                    _tabItem('MON - SAT', selected: isMonToSat),
                    _tabItem('SUNDAY', selected: !isMonToSat),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFB4B7C2), height: 1),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<BusSchedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No schedules available."));
          }
          return _buildScheduleContent(snapshot.data!);
        },
      ),
    );
  }

  // --- UI Building Methods ---

  Widget _tabItem(String text, {required bool selected}) {
    return GestureDetector(
      // FIX: Logic updated for new tab names
      onTap: () => setState(() {
        isMonToSat = text == 'MON - SAT';
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: selected
              ? const Border(bottom: BorderSide(color: Color(0xFF97DB50), width: 3))
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : const Color(0xFF687A8C),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(List<BusSchedule> allSchedules) {
    final allRuns = allSchedules.expand((schedule) => schedule.runs).toList();

    // FIX: Filter logic now uses the isMonToSat boolean
    final runsForDayType = allRuns
        .where((run) =>
    isMonToSat ? run.scheduleType == ScheduleType.WEEKDAY : run.scheduleType == ScheduleType.WEEKEND)
        .toList();

    final Map<String, List<BusRun>> runsByDirection = {};
    for (var run in runsForDayType) {
      if (run.route.stops.length < 2) continue;
      final from = run.route.stops.first.locationName;
      final to = run.route.stops.last.locationName;
      final key = "$from to $to";
      runsByDirection.putIfAbsent(key, () => []).add(run);
    }

    final sortedKeys = runsByDirection.keys.toList()..sort();

    if (runsByDirection.isEmpty) {
      return const Center(child: Text("No buses scheduled for this day."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final runsForSection = runsByDirection[key]!;
        runsForSection.sort((a,b) => _compareTimes(a.startTime, b.startTime));

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: _buildSection(
            title: key,
            runs: runsForSection,
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required List<BusRun> runs}) {
    if (runs.isEmpty) {
      return const SizedBox.shrink();
    }

    final from = runs.first.route.stops.first.locationName;
    final to = runs.first.route.stops.last.locationName;

    const iconColor = Color(0xFF132E9E);
    const textStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAFD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: iconColor)),
                    InkWell(
                      onTap: () => _showRouteModal(context, runs),
                      child: const Text('see routes', style: TextStyle(color: Color(0xFF1839C5), fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _locationIcon(from, textStyle, iconColor),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.arrow_forward, size: 16, color: iconColor),
                    ),
                    _locationIcon(to, textStyle, iconColor),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: runs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final run = runs[index];
            final int? leavesInMin = _calculateLeavesInMin(run.startTime);
            final bool isActive = leavesInMin != null;
            return _buildBusCard(run, isActive, leavesInMin);
          },
        ),
      ],
    );
  }

  Widget _locationIcon(String locationName, TextStyle style, Color color){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          locationName.contains('IITJ') ? Icons.school_outlined : Icons.location_city_outlined,
          color: color,
          size: 22,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 50,
          child: Text(
            locationName,
            style: style,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBusCard(BusRun run, bool isActive, int? leavesInMin) {
    final arrivalTime = run.route.stops.last.arrivalTime;

    Color borderColor = Colors.grey.shade300;
    List<BoxShadow> boxShadows = [];
    Color leavesInColor = const Color(0xFF4661D1);

    if (isActive) {
      borderColor = const Color(0xFF4661D1);
      boxShadows = [
        BoxShadow(color: const Color(0x1E2538C6), blurRadius: 26, offset: const Offset(0, 9)),
        BoxShadow(color: const Color(0x0A2538C6), blurRadius: 8, offset: const Offset(0, 8)),
      ];
      if (leavesInMin != null) {
        if (leavesInMin <= 15) {
          leavesInColor = const Color(0xFFF44960);
        } else if (leavesInMin <= 30) {
          leavesInColor = const Color(0xFFF29410);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: boxShadows,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isActive && leavesInMin != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontFamily: 'Rubik', color: leavesInColor),
                    children: [
                      const TextSpan(text: 'Leaves in ', style: TextStyle(fontSize: 10)),
                      TextSpan(text: '$leavesInMin min', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Text(
                    formatTime(run.startTime),
                    style: const TextStyle(fontSize: 18, fontFamily: 'Bricolage Grotesque', fontWeight: FontWeight.w600)
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('·········', style: TextStyle(color: Colors.grey, letterSpacing: 2))),
                const SizedBox(width: 8),
                Text(
                    formatTime(arrivalTime),
                    style: const TextStyle(color: Color(0xFF434B66), fontSize: 14)
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFEAF6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(run.busNumber, style: const TextStyle(color: Color(0xFF46515D), fontSize: 10, fontWeight: FontWeight.w400)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteModal(BuildContext context, List<BusRun> runs) {
    if (runs.isEmpty) return;

    final Map<String, RouteStop> uniqueStops = {};
    for (final run in runs) {
      for (final stop in run.route.stops) {
        uniqueStops.putIfAbsent(stop.locationName, () => stop);
      }
    }
    final sortedStops = uniqueStops.values.toList()
      ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

    final from = sortedStops.first.locationName;
    final to = sortedStops.last.locationName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('See Route', style: TextStyle(fontSize: 20, fontFamily: 'Bricolage Grotesque', fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Text('Routes are subject to change and are tentative', style: TextStyle(fontSize: 12, color: Color(0xFF4D4D4D), fontFamily: 'Rubik')),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8EAFD),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(from, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Bricolage Grotesque')),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward, size: 16),
                    ),
                    Text(to, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Bricolage Grotesque')),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedStops.length,
                  itemBuilder: (context, index) {
                    return _buildRouteStopRow(
                      sortedStops[index],
                      isFirst: index == 0,
                      isLast: index == sortedStops.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteStopRow(RouteStop stop, {required bool isFirst, required bool isLast}) {
    final isFirstOrLast = isFirst || isLast;
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: isFirst ? Colors.transparent : const Color(0xFF9EA3B0),
                  ),
                ),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                      color: Color(0xFF9EA3B0),
                      shape: BoxShape.circle
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: isLast ? Colors.transparent : const Color(0xFF9EA3B0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                stop.locationName,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Rubik',
                  fontWeight: isFirstOrLast ? FontWeight.w600 : FontWeight.w400,
                  color: const Color(0xFF282E3D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Logic ---

  int _compareTimes(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
  }

  int? _calculateLeavesInMin(TimeOfDay scheduledTime) {
    final now = DateTime.now();
    var scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final difference = scheduledDateTime.difference(now);

    if (difference.isNegative) return null;
    return difference.inMinutes <= 60 ? difference.inMinutes : null;
  }

  int _findNextBusIndex(List<BusRun> runs) {
    int? closestIndex;
    int? minDiff;
    for (int i = 0; i < runs.length; i++) {
      final diff = _calculateLeavesInMin(runs[i].startTime);
      if (diff != null) {
        if (minDiff == null || diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
    }
    return closestIndex ?? -1;
  }
}