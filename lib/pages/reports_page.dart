import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsPage extends StatefulWidget {
  final List<Map<String, dynamic>> timers;

  ReportsPage({required this.timers});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _groupTabController;
  Map<String, Map<String, Map<String, int>>> timerData = {};
  List<String> activeGroups = [];
  bool noData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  void loadData() async {
    timerData = await fetchTimeData(31);
    filterActiveGroups();
    checkForData();
    setState(() {});
  }

  void filterActiveGroups() {
    Set<String> groupsWithData = timerData.keys
        .where((group) => timerData[group]!
            .values
            .any((timers) => timers.values.any((time) => time > 0)))
        .toSet();
    activeGroups = groupsWithData.toList();
    _groupTabController =
        TabController(length: activeGroups.length + 1, vsync: this);
  }

  void checkForData() {
    noData = activeGroups.isEmpty;
  }

  Future<Map<String, Map<String, Map<String, int>>>> fetchTimeData(
      int days) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, Map<String, Map<String, int>>> data = {};
    DateTime today = DateTime.now();

    for (var timer in widget.timers) {
      String group = timer['group'];
      String timerName = timer['name'];

      if (!data.containsKey(group)) {
        data[group] = {};
      }

      for (int i = 0; i < days; i++) {
        String dateKey =
            today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        String key = '$dateKey-$group-$timerName';
        int timeSpent = prefs.getInt(key) ?? 0;

        if (!data[group]!.containsKey(timerName)) {
          data[group]![timerName] = {};
        }
        data[group]![timerName]![dateKey] = timeSpent;
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: noData
          ? _buildNoDataView()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
                  child: TabBar(
                    dividerColor: Color(0xF7F7F7),
                    tabAlignment: TabAlignment.center,
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: Color(0xFFE8EFFD),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: -10,
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Color(0xFF2963E8),
                    unselectedLabelColor: Color(0xFF777F89),
                    labelStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 22 / 14,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 22 / 14,
                      color: Color(0xFF777F89),
                    ),
                    tabs: [
                      _buildPrimaryTab('Weekly'),
                      _buildPrimaryTab('Monthly'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 8.h,
                    top: 5.h,
                    left: 8.w,
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    dividerColor: Color(0xF7F7F7),
                    controller: _groupTabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: -10,
                          blurRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.black,
                    unselectedLabelColor: Color(0xFF777F89),
                    labelStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 22 / 14,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 22 / 14,
                      color: Color(0xFF777F89),
                    ),
                    tabs: [
                      _buildSecondaryTab('All'),
                      ...activeGroups
                          .map((group) => _buildSecondaryTab(group))
                          .toList(),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _groupTabController,
                    children: [
                      _buildAllReports(),
                      ...activeGroups
                          .map((group) => _buildGroupReports(group))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPrimaryTab(String text) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 59.25.w),
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  Widget _buildSecondaryTab(String text) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 132.h),
          Image.asset(
            'assets/data.png',
            width: 73.62.w,
            height: 70.h,
            color: Color(0xFFC9C9C9),
          ),
          SizedBox(height: 10.h),
          Text(
            'No data to display yet.',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              fontSize: 24.sp,
              height: 28.64 / 24,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Create timers and start tracking your \nactivities to see reports.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              height: 19.09 / 16,
              color: Color(0xFF777F89),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllReports() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildReportView(timerData, true),
        _buildReportView(timerData, false),
      ],
    );
  }

  Widget _buildGroupReports(String group) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGroupReportView(group, timerData, true),
        _buildGroupReportView(group, timerData, false),
      ],
    );
  }

  Widget _buildGroupReportView(String group,
      Map<String, Map<String, Map<String, int>>> data, bool isWeekly) {
    Map<String, Map<String, int>> groupData = data[group]!;

    List<Map<String, dynamic>> usedTimers = widget.timers
        .where((timer) =>
            timer['group'] == group &&
            groupData[timer['name']]!.values.any((time) => time > 0))
        .toList();

    if (usedTimers.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: usedTimers.map((timer) {
        String timerName = timer['name'];
        int totalTime = 0;

        groupData[timerName]?.forEach((date, time) {
          totalTime += time;
        });

        return _buildActivityCard(
          timerName,
          isWeekly ? 'Last 7 days' : 'Last 31 days',
          _formatTotalTime(totalTime),
          _buildBarChartForTimer(timerName, groupData[timerName]!, isWeekly),
        );
      }).toList(),
    );
  }

  Widget _buildBarChartForTimer(
      String timerName, Map<String, int> timerData, bool isWeekly) {
    List<BarChartGroupData> barGroups = [];
    DateTime today = DateTime.now();

    double maxValue = 50.1;
    if (isWeekly) {
      for (int i = 6; i >= 0; i--) {
        String dateKey =
            today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        int timeInSeconds = timerData[dateKey] ?? 0;
        double timeInMinutes = timeInSeconds / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: 6 - i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      List<int> segments = [7, 7, 7, 7, 3];

      int segmentStart = 0;
      for (int i = 0; i < segments.length; i++) {
        int segmentTime = 0;

        for (int j = segmentStart; j < segmentStart + segments[i]; j++) {
          String dateKey = today
              .subtract(Duration(days: 30 - j))
              .toIso8601String()
              .split('T')[0];
          segmentTime += timerData[dateKey] ?? 0;
        }

        double timeInMinutes = segmentTime / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );

        segmentStart += segments[i];
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp,
                  height: 1.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                _getSegmentName(value.toInt(), isWeekly, today),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 1.5.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black,
              strokeWidth: 0.3,
            );
          },
          checkToShowHorizontalLine: (value) {
            return value % 10 == 0;
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildReportView(
      Map<String, Map<String, Map<String, int>>> data, bool isWeekly) {
    List<String> usedGroups = data.keys
        .where((group) => data[group]!
            .values
            .any((timerData) => timerData.values.any((time) => time > 0)))
        .toList();

    int totalAllActivitiesTime = usedGroups.fold(
      0,
      (total, group) =>
          total +
          data[group]!.values.fold(
              0,
              (sum, timerData) =>
                  sum + timerData.values.fold(0, (sum, time) => sum + time)),
    );

    if (totalAllActivitiesTime == 0 && usedGroups.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        if (totalAllActivitiesTime > 0)
          _buildActivityCard(
            'All activities',
            isWeekly ? 'Last 7 days' : 'Last 31 days',
            _formatTotalTime(totalAllActivitiesTime),
            _buildAllActivitiesBarChart(data, isWeekly),
          ),
        ...usedGroups.map((group) {
          int totalTime = data[group]!.values.fold(
              0,
              (sum, timerData) =>
                  sum + timerData.values.fold(0, (sum, time) => sum + time));

          return _buildActivityCard(
            group,
            isWeekly ? 'Last 7 days' : 'Last 31 days',
            _formatTotalTime(totalTime),
            _buildBarChart(group, data[group]!, isWeekly),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActivityCard(
      String title, String period, String totalTime, Widget chart) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 108.h,
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: -10,
              blurRadius: 2,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.h,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  period,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 1.2.h,
                    color: Color(0xFF777F89),
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  totalTime,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.h,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Total time',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    height: 1.h,
                    color: Color(0xFF777F89),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 202.w,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllActivitiesBarChart(
      Map<String, Map<String, Map<String, int>>> data, bool isWeekly) {
    List<BarChartGroupData> barGroups = [];
    DateTime today = DateTime.now();

    double maxValue = 50.1;
    if (isWeekly) {
      for (int i = 6; i >= 0; i--) {
        String dateKey =
            today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        int totalDayTime = 0;

        for (var group in data.keys) {
          for (var timerData in data[group]!.values) {
            totalDayTime += timerData[dateKey] ?? 0;
          }
        }

        double timeInMinutes = totalDayTime / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: 6 - i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      List<int> segments = [7, 7, 7, 7, 3];

      int segmentStart = 0;
      for (int i = 0; i < segments.length; i++) {
        int segmentTime = 0;

        for (int j = segmentStart; j < segmentStart + segments[i]; j++) {
          String dateKey = today
              .subtract(Duration(days: 30 - j))
              .toIso8601String()
              .split('T')[0];
          for (var group in data.keys) {
            for (var timerData in data[group]!.values) {
              segmentTime += timerData[dateKey] ?? 0;
            }
          }
        }

        double timeInMinutes = segmentTime / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );

        segmentStart += segments[i];
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp,
                  height: 1.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                _getSegmentName(value.toInt(), isWeekly, today),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 1.5.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black,
              strokeWidth: 0.3,
            );
          },
          checkToShowHorizontalLine: (value) {
            return value % 10 == 0;
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildBarChart(
      String group, Map<String, Map<String, int>> groupData, bool isWeekly) {
    List<BarChartGroupData> barGroups = [];
    DateTime today = DateTime.now();

    double maxValue = 50.1;
    if (isWeekly) {
      for (int i = 6; i >= 0; i--) {
        String dateKey =
            today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        int totalGroupTime = groupData.values
            .fold(0, (total, timerData) => total + (timerData[dateKey] ?? 0));
        double timeInMinutes = totalGroupTime / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: 6 - i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      List<int> segments = [7, 7, 7, 7, 3];

      int segmentStart = 0;
      for (int i = 0; i < segments.length; i++) {
        int segmentTime = 0;

        for (int j = segmentStart; j < segmentStart + segments[i]; j++) {
          String dateKey = today
              .subtract(Duration(days: 30 - j))
              .toIso8601String()
              .split('T')[0];
          segmentTime += groupData.values
              .fold(0, (total, timerData) => total + (timerData[dateKey] ?? 0));
        }

        double timeInMinutes = segmentTime / 60.0;

        if (timeInMinutes > maxValue) {
          maxValue = (timeInMinutes + 9).ceilToDouble();
        }

        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: timeInMinutes,
                color:
                    timeInMinutes > 0 ? Color(0xFF2963E8) : Colors.transparent,
                width: 14.w,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.r),
                  topRight: Radius.circular(3.r),
                ),
              ),
            ],
          ),
        );

        segmentStart += segments[i];
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp,
                  height: 1.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                _getSegmentName(value.toInt(), isWeekly, today),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 1.5.h,
                  color: Color(0xFF777F89),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black,
              strokeWidth: 0.3,
            );
          },
          checkToShowHorizontalLine: (value) {
            return value % 10 == 0;
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  String _getSegmentName(int index, bool isWeekly, DateTime today) {
    if (isWeekly) {
      return _getDayName(today.subtract(Duration(days: 6 - index)).weekday);
    } else {
      DateTime startDate = today.subtract(Duration(days: 30 - index * 7));
      DateTime endDate = startDate.add(Duration(days: index == 4 ? 2 : 6));
      return '${startDate.day}-${endDate.day}';
    }
  }

  String _formatTotalTime(int totalTimeInSeconds) {
    int hours = totalTimeInSeconds ~/ 3600;
    int minutes = (totalTimeInSeconds % 3600) ~/ 60;
    int seconds = totalTimeInSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
