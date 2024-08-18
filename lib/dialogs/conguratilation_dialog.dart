import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CongratulationDialog extends StatelessWidget {
  final String timerName;
  final String spentTime;
  final VoidCallback onCheckReport;
  final VoidCallback onBack;

  CongratulationDialog({
    required this.timerName,
    required this.spentTime,
    required this.onCheckReport,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Color(0xFF000000),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 25.r, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Image.asset(
              'assets/conguratilation.png',
              width: 97.w,
              height: 94.h,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'You have achieved your goal!',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Your persistence and hard work have paid off, bringing you one step closer to mastery.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: Color(0xFF777F89),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(1.w),
                1: FlexColumnWidth(2.w),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      'Skill',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Color(0xFF777F89),
                      ),
                    ),
                    Text(
                      'Spent time',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Color(0xFF777F89),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        timerName,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        spentTime,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.all(13.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onBack,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(105.w, 38.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Color(0xFF777F89),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onCheckReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2963E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    fixedSize: Size(156.5.w, 38.h),
                  ),
                  child: Text(
                    'Check report',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
