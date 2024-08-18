import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PremiumBottomSheet extends StatelessWidget {
  final VoidCallback onUnlockPremium;

  PremiumBottomSheet({required this.onUnlockPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get ',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Pro',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem('Access to over 60+ various templates', true),
          _buildFeatureItem('Insightful learning time estimates', true),
          _buildFeatureItem('Set realistic learning expectations', true),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onUnlockPremium();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                backgroundColor: Color(0xFF2963E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                'Unlock premium \$0.99',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30.h,
          )
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isChecked) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check : Icons.close,
            color: isChecked ? Colors.green : Colors.red,
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
