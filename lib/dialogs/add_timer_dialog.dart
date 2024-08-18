import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddTimerDialog extends StatefulWidget {
  final List<Map<String, dynamic>> groups;
  final Function(String, int, int, int, String, String) onSave;
  final Function(String, String) onAddGroup;

  AddTimerDialog({
    required this.groups,
    required this.onSave,
    required this.onAddGroup,
  });

  @override
  _AddTimerDialogState createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<AddTimerDialog> {
  final TextEditingController _timerNameController = TextEditingController();
  final TextEditingController _newGroupController = TextEditingController();
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  String? _selectedGroup;
  String? _selectedIconPath;
  bool _isAddingNewGroup = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add new timer',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 24 / 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black, size: 25.r),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Color(0xFFC6C8CC),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _timerNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    fillColor: Color(0xFFEFEFF0),
                    filled: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: Icon(Icons.edit_outlined,
                          color: Color(0xFF3C3C43).withOpacity(0.6),
                          size: 20.r),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 20.w,
                      minHeight: 20.h,
                    ),
                    hintText: 'Name of the new timer',
                    hintStyle: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 22 / 14,
                      color: Color(0xFF3C3C43).withOpacity(0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Color(0xFFC6C8CC),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                child: Text(
                  'Set timer',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 1.h,
                    color: Color(0xFF777F89),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TimerInputField(
                      label: 'hours',
                      value: _hours,
                      onChanged: (val) => setState(() => _hours = val),
                    ),
                    SizedBox(width: 8.w),
                    TimerInputField(
                      label: 'min',
                      value: _minutes,
                      onChanged: (val) => setState(() => _minutes = val),
                    ),
                    SizedBox(width: 8.w),
                    TimerInputField(
                      label: 'sec',
                      value: _seconds,
                      onChanged: (val) => setState(() => _seconds = val),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Color(0xFFC6C8CC),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Choose group',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 22 / 14,
                    color: Color(0xFF777F89),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                height: widget.groups.length > 6 ? 180.h : null,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.groups.length,
                  itemBuilder: (context, index) {
                    final group = widget.groups[index];
                    final isSelected = group['name'] == _selectedGroup;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGroup = group['name'];
                          _selectedIconPath = group['iconPath'];
                        });
                      },
                      child: Row(
                        children: [
                          if (isSelected)
                            Icon(Icons.check,
                                color: Color(0xFF2963E8), size: 20.r),
                          SizedBox(width: isSelected ? 8.w : 28.w),
                          Text(
                            group['name'],
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              height: 22 / 14,
                              color:
                                  isSelected ? Color(0xFF2963E8) : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Color(0xFFC6C8CC),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _isAddingNewGroup
                    ? _buildNewGroupInputField()
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAddingNewGroup = true;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.black),
                            SizedBox(width: 8.w),
                            Text(
                              'New group',
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                height: 14 / 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Color(0xFFC6C8CC),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_timerNameController.text.isNotEmpty &&
                          _selectedGroup != null &&
                          _selectedIconPath != null) {
                        widget.onSave(
                          _timerNameController.text,
                          _hours,
                          _minutes,
                          _seconds,
                          _selectedGroup!,
                          _selectedIconPath!,
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please complete all fields'),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2963E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      fixedSize: Size(130.w, 38.h),
                    ),
                    child: Text(
                      'Set timer',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.r,
                        height: 1.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewGroupInputField() {
    return TextField(
      controller: _newGroupController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        fillColor: Color(0xFFEFEFF0),
        filled: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w),
          child: GestureDetector(
            onTap: () {
              if (_newGroupController.text.isNotEmpty) {
                String newGroupName = _newGroupController.text.trim();
                String newGroupIconPath = 'assets/icons/new_group.png';

                if (widget.groups
                    .any((group) => group['name'] == newGroupName)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Group name already exists.'),
                  ));
                } else {
                  widget.onAddGroup(newGroupName, newGroupIconPath);

                  setState(() {
                    _selectedGroup = newGroupName;
                    _selectedIconPath = newGroupIconPath;
                    _newGroupController.clear();
                    _isAddingNewGroup = false;
                  });
                }
              }
            },
            child: Icon(Icons.check, color: Color(0xFF777F89), size: 20.r),
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 20.w,
          minHeight: 20.h,
        ),
        hintText: 'Write name to new group',
        hintStyle: TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          height: 22 / 14,
          color: Color(0xFF777F89),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class TimerInputField extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  TimerInputField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => onChanged(value + 1),
            borderRadius: BorderRadius.circular(3.r),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: -1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.keyboard_arrow_up_outlined,
                color: Color(0xFF777F89),
                size: 24.r,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Column(
            children: [
              Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w500,
                  fontSize: 24.sp,
                  height: 22 / 24,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  height: 12 / 12,
                  color: Color(0xFF777F89),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: () => onChanged(value - 1),
            borderRadius: BorderRadius.circular(3.r),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: -1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Color(0xFF777F89),
                size: 24.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
