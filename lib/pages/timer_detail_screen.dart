import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/conguratilation_dialog.dart';
import '../dialogs/timer_settings_dialog.dart';

class TimerDetailScreen extends StatefulWidget {
  late final Map<String, dynamic> timer;
  final void Function(Map<String, dynamic> updatedTimer)? onUpdateTimer;
  final List<Map<String, dynamic>> groups;
  final VoidCallback onNavigateToReports;

  TimerDetailScreen({
    required this.timer,
    required this.groups,
    this.onUpdateTimer,
    required this.onNavigateToReports,
  });

  @override
  _TimerDetailScreenState createState() => _TimerDetailScreenState();
}

class _TimerDetailScreenState extends State<TimerDetailScreen> {
  List<Map<String, dynamic>> _notes = [];
  Timer? _timer;
  DateTime? _startTime;
  FocusNode? activeFocusNode;
  TextEditingController? _zeroHourTextController;
  final Map<String, TextEditingController> _textControllers = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _zeroHourTextController = TextEditingController();
    _loadTimerState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.timer['isRunning'] == true &&
          widget.timer['remainingSeconds'] > 0) {
        _startTimer(widget.timer);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;

    _zeroHourTextController?.dispose();
    _zeroHourTextController = null;

    _textControllers.forEach((key, controller) {
      controller.dispose();
    });
    _textControllers.clear();

    activeFocusNode?.dispose();
    activeFocusNode = null;

    super.dispose();
  }

  Future<void> _loadTimerState() async {
    _startTime = widget.timer['startTime'] != null
        ? DateTime.tryParse(widget.timer['startTime'].toString())
        : null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotesJson =
        prefs.getStringList('notes_${widget.timer['name']}');
    if (savedNotesJson != null) {
      if (!_isDisposed) {
        setState(() {
          _notes = savedNotesJson
              .map((note) => jsonDecode(note))
              .cast<Map<String, dynamic>>()
              .toList();
        });
      }
    }

    if (_notes.isEmpty) {
      final timestamp = DateTime.now().toIso8601String();
      _notes.add({
        'time': 'Zero-Hour',
        'text': '',
        'timestamp': timestamp,
      });
    }

    _zeroHourTextController?.text = _notes[0]['text'];
    _textControllers[_notes[0]['timestamp']] = _zeroHourTextController!;

    for (var note in _notes) {
      if (!_textControllers.containsKey(note['timestamp'])) {
        _textControllers[note['timestamp']] =
            TextEditingController(text: note['text']);
      }
    }
  }

  void _startTimer(Map<String, dynamic> timer) {
    setState(() {
      if (_startTime == null) {
        _startTime = DateTime.now();
        timer['startTime'] = _startTime!.toIso8601String();
      }

      timer['isRunning'] = true;
      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (!_isDisposed) {
          setState(() => _decrementTimer(timer));
        }
      });
    });
    _saveTimerState();
    if (widget.onUpdateTimer != null && !_isDisposed) {
      widget.onUpdateTimer!(timer);
    }
  }

  void _decrementTimer(Map<String, dynamic> timer) {
    if (timer['remainingSeconds'] > 0) {
      timer['remainingSeconds']--;
      _checkForNoteAddition();
    } else {
      _stopTimer(timer);
      _showCongratulationDialog();
    }
  }

  void _checkForNoteAddition() {
    if (_startTime == null) return;

    final intervalsElapsed = DateTime.now().difference(_startTime!).inHours;

    while (_notes.length <= intervalsElapsed) {
      final timestamp = DateTime.now().toIso8601String();
      _notes.add({
        'time': timestamp,
        'text': '',
        'timestamp': timestamp,
      });
      _textControllers[timestamp] = TextEditingController();
    }

    _saveTimerState();
  }

  void _stopTimer(Map<String, dynamic> timer) {
    setState(() {
      timer['isRunning'] = false;
      _timer?.cancel();
      _saveTimerState();
    });
    if (widget.onUpdateTimer != null && !_isDisposed) {
      widget.onUpdateTimer!(timer);
    }
  }

  void _showCongratulationDialog() {
    if (_isDisposed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CongratulationDialog(
          timerName: widget.timer['name'],
          spentTime: _formatTotalTime(widget.timer['hours'] * 3600 +
              widget.timer['minutes'] * 60 +
              widget.timer['seconds']),
          onCheckReport: () {
            Navigator.of(context).pushNamed('/reports');
          },
          onBack: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  String _formatTotalTime(int totalTimeInSeconds) {
    int hours = totalTimeInSeconds ~/ 3600;
    int minutes = (totalTimeInSeconds % 3600) ~/ 60;
    int seconds = totalTimeInSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveTimerState() async {
    if (_isDisposed) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> notesJson = _notes.map((note) {
      return jsonEncode({
        'time': note['time'],
        'text': _textControllers[note['timestamp']]?.text ?? '',
        'timestamp': note['timestamp'],
      });
    }).toList();

    await prefs.setStringList('notes_${widget.timer['name']}', notesJson);

    List<Map<String, dynamic>> timerList =
        (jsonDecode(prefs.getString('timers') ?? '[]') as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

    timerList.removeWhere((t) => t['name'] == widget.timer['name']);
    widget.timer['startTime'] = _startTime?.toIso8601String();
    timerList.add(widget.timer);
    await prefs.setString('timers', jsonEncode(timerList));
  }

  void _showSettingsDialog() {
    if (_isDisposed) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return TimerSettingsDialog(
          timer: widget.timer,
          groups: widget.groups,
          onSave: (updatedTimer) {
            setState(() {
              widget.timer['name'] = updatedTimer['name'];
              widget.timer['group'] = updatedTimer['group'];
              widget.timer['remainingSeconds'] =
                  updatedTimer['remainingSeconds'];
              if (widget.timer['remainingSeconds'] > 0) {
                widget.timer['isRunning'] = false;
              }
            });
            if (widget.onUpdateTimer != null && !_isDisposed) {
              widget.onUpdateTimer!(widget.timer);
            }
          },
          onDelete: _deleteTimer,
        );
      },
    );
  }

  void _deleteTimer() async {
    if (_isDisposed) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> timerList =
        (jsonDecode(prefs.getString('timers') ?? '[]') as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
    timerList.removeWhere((t) => t['name'] == widget.timer['name']);
    await prefs.setString('timers', jsonEncode(timerList));

    await prefs.remove('notes_${widget.timer['name']}');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeLeft = Duration(seconds: widget.timer['remainingSeconds']);
    final elapsedTime = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.r,
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
        title: Text(
          widget.timer['name'],
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            height: 23.87.sp / 20.sp,
            color: Colors.black,
          ),
        ),
        actions: [
          if (widget.timer['remainingSeconds'] == 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              margin: EdgeInsets.only(right: 10.w),
              decoration: BoxDecoration(
                color: Color(0xFFEAFDE8),
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Text(
                'Completed',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 16.71.sp / 14.sp,
                  color: Color(0xFF08A045),
                ),
              ),
            ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimerCard(),
              SizedBox(height: 20.h),
              Text(
                'Zero-hour note',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 16.71.sp / 14.sp,
                  color: Color(0xFF777F89),
                ),
              ),
              SizedBox(height: 10.h),
              if (_notes.isNotEmpty)
                _buildNoteCard(_notes[0], isZeroHour: true),
              SizedBox(height: 20.h),
              Text(
                'Notes',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 16.71.sp / 14.sp,
                  color: Color(0xFF777F89),
                ),
              ),
              SizedBox(height: 10.h),
              _buildNotesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    final timeLeft = Duration(seconds: widget.timer['remainingSeconds']);
    final elapsedTime = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    final hours = timeLeft.inHours.toString().padLeft(2, '0');
    final minutes = (timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: 343.w,
      padding: EdgeInsets.all(16.w),
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
      child: Column(
        children: [
          Text(
            'Time left',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              height: 12.sp / 12.sp,
              letterSpacing: -0.41.sp,
              color: Color(0xFF777F89),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    hours,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      height: 22.sp / 24.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'hours',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 12.sp / 12.sp,
                      letterSpacing: -0.41.sp,
                      color: Color(0xFF777F89),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  Text(
                    minutes,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      height: 22.sp / 24.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'min',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 12.sp / 12.sp,
                      letterSpacing: -0.41.sp,
                      color: Color(0xFF777F89),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  Text(
                    seconds,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      height: 22.sp / 24.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'sec',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 12.sp / 12.sp,
                      letterSpacing: -0.41.sp,
                      color: Color(0xFF777F89),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _startTime != null
                        ? DateFormat('HH:mm:ss').format(_startTime!)
                        : 'Did not start yet',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 22.sp / 14.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8EFFD),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Text(
                      'Started time',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                        height: 15.sp / 10.sp,
                        color: Color(0xFF2963E8),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(elapsedTime ~/ 3600).toString().padLeft(2, '0')} : ${((elapsedTime % 3600) ~/ 60).toString().padLeft(2, '0')} : ${(elapsedTime % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 22.sp / 14.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8EFFD),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Text(
                      'Elapsed time',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                        height: 15.sp / 10.sp,
                        color: Color(0xFF2963E8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  size: 24.r,
                  color: Color(0xFF777F89),
                ),
                onPressed: _showSettingsDialog,
              ),
              ElevatedButton(
                onPressed: widget.timer['remainingSeconds'] > 0
                    ? () {
                        if (widget.timer['isRunning'] == true) {
                          _stopTimer(widget.timer);
                        } else {
                          _startTimer(widget.timer);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.timer['remainingSeconds'] > 0
                      ? (widget.timer['isRunning']
                          ? Color(0xFFD13535)
                          : Color(0xFF08A045))
                      : Color(0xFF9E9E9E),
                  fixedSize: Size(102.w, 36.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: Text(
                  widget.timer['isRunning'] ? 'Pause' : 'Start',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Icon(
                widget.timer['isRunning'] ? Icons.pause : Icons.play_arrow,
                size: 24.r,
                color: widget.timer['isRunning']
                    ? Color(0xFFEC7E00)
                    : Color(0xFF777F89),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, {bool isZeroHour = false}) {
    bool showPlaceholder = note['text'].isEmpty;
    final controller = isZeroHour
        ? _zeroHourTextController
        : _textControllers[note['timestamp']];
    FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.3,
          duration: Duration(milliseconds: 300),
        );

        if (activeFocusNode != null && activeFocusNode != focusNode) {
          activeFocusNode!.unfocus();
        }
        activeFocusNode = focusNode;
      }
    });

    DateTime noteDate = isZeroHour
        ? _startTime ?? DateTime.now()
        : DateTime.parse(note['time']);
    DateTime today = DateTime.now();

    String formattedDate;
    if (noteDate.year == today.year &&
        noteDate.month == today.month &&
        noteDate.day == today.day) {
      formattedDate = 'Today, ${DateFormat('h:mm a').format(noteDate)}';
    } else {
      formattedDate = DateFormat('dd MMM yyyy, h:mm a').format(noteDate);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.r),
        border: Border(
          left: BorderSide(
            color: Color(0xFF2963E8),
            width: 3.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 16.71.sp / 14.sp,
              letterSpacing: -0.41.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Color(0xFFEFEFF0),
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Row(
              children: [
                if (showPlaceholder)
                  Icon(
                    Icons.edit,
                    size: 18.r,
                    color: Color(0xFF3C3C43).withOpacity(0.6),
                  ),
                if (showPlaceholder) SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: showPlaceholder
                          ? DateFormat('h:mm a').format(
                              isZeroHour
                                  ? _startTime ?? DateTime.now()
                                  : DateTime.parse(note['time']),
                            )
                          : '',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
                    ),
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      height: 22.sp / 13.sp,
                      letterSpacing: -0.41.sp,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Scrollable.ensureVisible(context,
                          duration: Duration(milliseconds: 300));
                    },
                    onChanged: (value) {
                      if (_isDisposed) return;
                      setState(() {
                        note['text'] = value;
                        controller?.text = value;
                        controller?.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                        _saveTimerState();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.length <= 1) return Container();

    Map<String, List<Map<String, dynamic>>> groupedNotes = {};

    for (var note in _notes.skip(1)) {
      String dateKey = DateFormat('dd MMM yyyy, h:mm a')
          .format(DateTime.parse(note['time']));
      if (groupedNotes.containsKey(dateKey)) {
        groupedNotes[dateKey]!.add(note);
      } else {
        groupedNotes[dateKey] = [note];
      }
    }

    return Column(
      children: groupedNotes.entries.map((entry) {
        return Container(
          width: 343.w,
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.only(bottom: 10.h),
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
            border: Border(
              left: BorderSide(
                color: Color(0xFF2963E8),
                width: 3.w,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 16.71.sp / 14.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              ...entry.value.map((note) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildNoteTextField(note),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteTextField(Map<String, dynamic> note) {
    bool showPlaceholder = note['text'].isEmpty;
    TextEditingController? controller = _textControllers[note['timestamp']];
    FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.3,
          duration: Duration(milliseconds: 300),
        );

        if (activeFocusNode != null && activeFocusNode != focusNode) {
          activeFocusNode!.unfocus();
        }
        activeFocusNode = focusNode;
      }
    });

    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Color(0xFFEFEFF0),
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        children: [
          if (showPlaceholder)
            Icon(
              Icons.edit,
              size: 18.r,
              color: Color(0xFF3C3C43).withOpacity(0.6),
            ),
          if (showPlaceholder) SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: showPlaceholder
                    ? DateFormat('h:mm a').format(
                        DateTime.parse(note['time']),
                      )
                    : '',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
              ),
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
                height: 22.sp / 13.sp,
                letterSpacing: -0.41.sp,
                color: Colors.black,
              ),
              onTap: () {
                Scrollable.ensureVisible(context,
                    duration: Duration(milliseconds: 300));
              },
              onChanged: (value) {
                if (_isDisposed) return;
                setState(() {
                  note['text'] = value;
                  controller?.text = value;
                  controller?.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                  _saveTimerState();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
