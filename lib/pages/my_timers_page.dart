import 'dart:async';
import 'dart:convert';

import 'package:actimers/pages/timer_detail_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/conguratilation_dialog.dart';

class MyTimersPage extends StatefulWidget {
  final List<Map<String, dynamic>> groups;
  final List<Map<String, dynamic>> timers;
  final void Function(String group, int seconds) onTimeSpentUpdated;
  final VoidCallback onNavigateToReports;

  MyTimersPage({
    required this.groups,
    required this.timers,
    required this.onTimeSpentUpdated,
    required this.onNavigateToReports,
  });

  @override
  _MyTimersPageState createState() => _MyTimersPageState();
}

class _MyTimersPageState extends State<MyTimersPage>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  @override
  void didUpdateWidget(MyTimersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeTabController();
  }

  Future<void> _loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timersJson = prefs.getString('timers');
    if (timersJson != null) {
      List<dynamic> loadedTimers = jsonDecode(timersJson);
      setState(() {
        widget.timers.clear();
        for (var timer in loadedTimers) {
          Map<String, dynamic> loadedTimer = Map<String, dynamic>.from(timer);
          if (loadedTimer['startTime'] != null &&
              loadedTimer['startTime'] is int) {
            loadedTimer['startTime'] =
                DateTime.fromMillisecondsSinceEpoch(loadedTimer['startTime']);
          }
          widget.timers.add(loadedTimer);
        }
        _initializeTabController();
      });
      print('Timers loaded: ${widget.timers}');
    }
  }

  void _initializeTabController() {
    Set<String> groupsWithTimers =
        widget.timers.map((e) => e['group'] as String).toSet();
    final tabCount = groupsWithTimers.length + 1;

    if (_tabController == null || _tabController!.length != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<String> groupsWithTimers =
        widget.timers.map((e) => e['group'] as String).toSet();

    bool hasTimers = widget.timers.isNotEmpty;

    if (!hasTimers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 120.h),
            Image.asset(
              'assets/logo.png',
              width: 70.w,
              height: 70.h,
              color: Color(0xFF777F89),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your timer space is waiting!',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 24.sp,
                height: 28.64 / 24,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Add a new timer or group to start tracking \nyour achievements.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                height: 19.09 / 16,
                color: Color(0xFF777F89),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_tabController != null &&
            _tabController!.length > 0 &&
            hasTimers) ...[
          Padding(
            padding: EdgeInsets.only(left: 10.w, bottom: 8.h, top: 16.h),
            child: TabBar(
              tabAlignment: TabAlignment.start,
              dividerColor: Color(0xF7F7F7),
              controller: _tabController,
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
                _buildTab('All'),
                ...widget.groups
                    .where((g) => groupsWithTimers.contains(g['name']))
                    .map((group) => _buildTab(group['name']))
                    .toList(),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimersList(widget.timers),
                ...widget.groups
                    .where((g) => groupsWithTimers.contains(g['name']))
                    .map((group) {
                  final groupTimers = widget.timers
                      .where((timer) => timer['group'] == group['name'])
                      .toList();
                  return _buildTimersList(groupTimers);
                }).toList(),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildTab(String text) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      child: Text(text),
    );
  }

  Widget _buildTimersList(List<Map<String, dynamic>> timers) {
    if (timers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 120.h),
            Image.asset(
              'assets/logo.png',
              width: 70.w,
              height: 70.h,
              color: Color(0xFF777F89),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your timer space is waiting!',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 24.sp,
                height: 28.64 / 24,
                color: Color(0xFF000000),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Add a new timer or group to start tracking \nyour achievements.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                height: 19.09 / 16,
                color: Color(0xFF777F89),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: timers.length,
        itemBuilder: (context, index) {
          final timer = timers[index];
          int remainingSeconds = timer['remainingSeconds'] ?? 0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimerDetailScreen(
                    timer: timer,
                    onUpdateTimer: (updatedTimer) {
                      setState(() {
                        timers[index] = updatedTimer;
                      });
                      _saveTimers();
                    },
                    groups: widget.groups,
                    onNavigateToReports: widget.onNavigateToReports,
                  ),
                ),
              ).then((_) {
                _loadTimers();
              });
            },
            onLongPress: () async {
              await _deleteTimer(timer);
              setState(() {
                timers.removeAt(index);
              });
              _saveTimers();
            },
            child: Container(
              height: 70.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          timer['iconPath'],
                          width: 44.r,
                          height: 44.r,
                        ),
                        SizedBox(width: 16.w),
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                timer['name'],
                                style: TextStyle(
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  height: 24 / 16,
                                  color: Color(0xFF000000),
                                ),
                                minFontSize: 12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 18.r,
                                    color: Color(0xFF777F89),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    '${(remainingSeconds ~/ 3600).toString().padLeft(2, '0')}:'
                                    '${((remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}:'
                                    '${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                      height: 21 / 14,
                                      color: Color(0xFF777F89),
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
                  IconButton(
                    icon: Icon(
                      timer['isRunning']
                          ? Icons.stop_circle
                          : Icons.play_circle,
                      size: 30.r,
                      color: timer['isRunning'] ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      if (timer['remainingSeconds'] > 0) {
                        if (timer['isRunning']) {
                          _stopTimer(timer);
                        } else {
                          _startTimer(timer);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'This timer has already completed!',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _startTimer(Map<String, dynamic> timer) {
    if (timer['remainingSeconds'] == 0 || timer['isRunning']) {
      return;
    }

    setState(() {
      timer['isRunning'] = true;
      timer['startTime'] = DateTime.now().toIso8601String();
      timer['timer'] = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() => _decrementTimer(timer));
      });
    });
  }

  void _decrementTimer(Map<String, dynamic> timer) {
    if (timer['remainingSeconds'] != null && timer['remainingSeconds'] > 0) {
      setState(() {
        timer['remainingSeconds']--;
      });
    } else {
      _stopTimer(timer);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CongratulationDialog(
            timerName: timer['name'],
            spentTime: _formatTotalTime(timer['hours'] * 3600 +
                timer['minutes'] * 60 +
                timer['seconds']),
            onCheckReport: () {
              Navigator.of(context).pop();
              widget.onNavigateToReports();
            },
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  String _formatTotalTime(int totalTimeInSeconds) {
    int hours = totalTimeInSeconds ~/ 3600;
    int minutes = (totalTimeInSeconds % 3600) ~/ 60;
    int seconds = totalTimeInSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _stopTimer(Map<String, dynamic> timer) {
    if (timer['timer'] != null) {
      timer['timer'].cancel();
      timer.remove('timer');
    }

    setState(() {
      timer['isRunning'] = false;
      DateTime endTime = DateTime.now();
      int duration =
          endTime.difference(DateTime.parse(timer['startTime'])).inSeconds;
      _saveTimeSpent(timer, duration);

      _saveTimers();
    });
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> timerList = widget.timers.map((timer) {
      Map<String, dynamic> newTimer = Map.from(timer);
      if (newTimer['startTime'] is DateTime) {
        newTimer['startTime'] =
            (newTimer['startTime'] as DateTime).millisecondsSinceEpoch;
      }
      return newTimer;
    }).toList();

    String timersJson = jsonEncode(timerList);
    await prefs.setString('timers', timersJson);
    print('Saved timers: ${widget.timers}');
  }

  Future<void> _saveTimeSpent(
      Map<String, dynamic> timer, int durationInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    String group = timer['group'];
    String timerName = timer['name'];
    String key =
        '${DateTime.now().toIso8601String().split('T')[0]}-$group-$timerName';
    int existingTime = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, existingTime + durationInSeconds);
  }

  Future<void> _deleteTimer(Map<String, dynamic> timer) async {
    final prefs = await SharedPreferences.getInstance();
    String group = timer['group'];
    String timerName = timer['name'];

    final allKeys = prefs.getKeys();

    for (String key in allKeys) {
      if (key.contains('-$group-$timerName')) {
        await prefs.remove(key);
      }
    }

    setState(() {
      widget.timers
          .removeWhere((t) => t['name'] == timerName && t['group'] == group);
    });

    await _clearTimerData(timer);

    await _saveTimers();
  }

  Future<void> _clearTimerData(Map<String, dynamic> timer) async {
    final prefs = await SharedPreferences.getInstance();
    String group = timer['group'];
    String timerName = timer['name'];

    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.contains('-$group-$timerName')) {
        await prefs.remove(key);
      }
    }
  }
}
