import 'dart:convert';

import 'package:actimers/pages/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialogs/add_group_dialog.dart';
import 'dialogs/add_timer_dialog.dart';
import 'pages/my_timers_page.dart';
import 'pages/settings_page.dart';
import 'pages/templates_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _timers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String? groupsJson = prefs.getString('groups');
    if (groupsJson != null) {
      List<dynamic> decodedGroups = jsonDecode(groupsJson);
      _groups = decodedGroups
          .map((group) => Map<String, dynamic>.from(group))
          .toList();
      print('Loaded groups: $_groups');
    }

    String? timersJson = prefs.getString('timers');
    if (timersJson != null) {
      List<dynamic> decodedTimers = jsonDecode(timersJson);
      _timers = decodedTimers
          .map((timer) => Map<String, dynamic>.from(timer))
          .toList();
      print('Loaded timers: $_timers');
    }

    setState(() {});
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    String groupsJson = jsonEncode(_groups);
    await prefs.setString('groups', groupsJson);
    print('Saved groups: $_groups');
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> timerList = _timers.map((timer) {
      if (timer['startDate'] is DateTime) {
        timer['startDate'] = (timer['startDate'] as DateTime).toIso8601String();
      }

      return Map<String, dynamic>.from(timer);
    }).toList();

    String timersJson = jsonEncode(timerList);
    await prefs.setString('timers', timersJson);
    print('Saved timers: $_timers');
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addGroup(String name, String iconPath) {
    setState(() {
      _groups.add({'name': name, 'iconPath': iconPath});
    });
    _saveGroups();
  }

  void _addTimer(String name, int hours, int minutes, int seconds, String group,
      String iconPath) {
    setState(() {
      bool groupExists = _groups.any((g) => g['name'] == group);
      if (!groupExists) {
        _addGroup(group, iconPath);
      }

      _timers.add({
        'name': name,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'group': group,
        'iconPath': iconPath,
        'isRunning': false,
        'remainingSeconds': hours * 3600 + minutes * 60 + seconds,
        'startDate': DateTime.now().toIso8601String(),
      });
    });
    _saveTimers();
  }

  void _navigateToReportsPage() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      appBar:
          _currentIndex == 0 ? _buildMyTimersAppBar() : _buildDefaultAppBar(),
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildMyTimersAppBar() {
    return AppBar(
      title: Text(
        'My Timers',
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
          height: 23.87 / 20,
          color: const Color(0xFF000000),
        ),
      ),
      toolbarHeight: 48.h,
      centerTitle: false,
      titleSpacing: 16.w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      actions: [
        _buildActionButton('Timer', () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AddTimerDialog(
                groups: _groups,
                onSave: _addTimer,
                onAddGroup: _addGroup,
              );
            },
          );
        }),
        Padding(
          padding: EdgeInsets.only(right: 16.w, left: 10.w),
          child: _buildActionButton('Group', () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AddGroupDialog(onSave: _addGroup);
              },
            );
          }),
        ),
      ],
    );
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(
        _getTitle(_currentIndex),
        style: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w500,
          fontSize: 20.sp,
          height: 23.87 / 20,
          color: const Color(0xFF000000),
        ),
      ),
      toolbarHeight: 48.h,
      centerTitle: false,
      titleSpacing: 16.w,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 82.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: Color.fromRGBO(232, 239, 253, 1),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 2,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Icon(
                Icons.add_circle_outline_rounded,
                color: Color.fromRGBO(41, 99, 232, 1),
                size: 20.r,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                height: 16.71 / 14,
                color: Color.fromRGBO(41, 99, 232, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return MyTimersPage(
          groups: _groups,
          timers: _timers,
          onTimeSpentUpdated: (String group, int seconds) {},
          onNavigateToReports: _navigateToReportsPage,
        );
      case 1:
        return TemplatesPage(onAddTimer: _addTimer);
      case 2:
        return ReportsPage(timers: _timers);
      case 3:
        return SettingsPage();
      default:
        return MyTimersPage(
          groups: _groups,
          timers: _timers,
          onTimeSpentUpdated: (String group, int seconds) {},
          onNavigateToReports: _navigateToReportsPage,
        );
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      selectedItemColor: const Color.fromRGBO(41, 99, 232, 1),
      unselectedItemColor: const Color.fromRGBO(119, 127, 137, 1),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5.h, top: 4),
            child: ImageIcon(
              const AssetImage('assets/icons/my_timers.png'),
              size: 24.r,
            ),
          ),
          label: 'My timers',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5.h, top: 4),
            child: ImageIcon(
              const AssetImage('assets/icons/templates.png'),
              size: 24.r,
            ),
          ),
          label: 'Templates',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5.h, top: 4),
            child: ImageIcon(
              const AssetImage('assets/icons/reports.png'),
              size: 24.r,
            ),
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5.h, top: 4),
            child: ImageIcon(
              const AssetImage('assets/icons/settings.png'),
              size: 24.r,
            ),
          ),
          label: 'Settings',
        ),
      ],
      selectedLabelStyle: TextStyle(
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        height: 14.32 / 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        height: 14.32 / 12,
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'My Timers';
      case 1:
        return 'Templates';
      case 2:
        return 'Reports';
      case 3:
        return 'Settings';
      default:
        return '';
    }
  }
}
