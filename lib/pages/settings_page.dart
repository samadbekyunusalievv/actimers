import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../premium_status_helper.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool premiumStatus = false;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    premiumStatus = await PremiumStatusHelper.getPremiumStatus();
    setState(() {});
  }

  Future<void> _updatePremiumStatus(bool status) async {
    await PremiumStatusHelper.setPremiumStatus(status);
    setState(() {
      premiumStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            if (premiumStatus)
              Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/premium.png',
                        width: 24.r,
                        height: 24.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Premium is yours',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!premiumStatus)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildProFeatureCard(),
              ),
            SizedBox(height: 20.h),
            _buildCardSettingsItem(
                'assets/icons/privacy.png', 'Privacy Policy', context),
            _buildCardSettingsItem(
                'assets/icons/terms.png', 'Terms & Conditions', context),
            _buildCardSettingsItem(
                'assets/icons/support.png', 'Support', context),
            _buildCardSettingsItem(
                'assets/icons/restore.png', 'Restore', context, () {
              _restorePremiumStatus();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProFeatureCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _updatePremiumStatus(true);
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
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildCardSettingsItem(
      String iconPath, String title, BuildContext context,
      [VoidCallback? onTap]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        iconPath,
                        width: 24.r,
                        height: 24.r,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_outlined,
                      color: Color(0xFF777F89), size: 20.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restorePremiumStatus() async {
    await _updatePremiumStatus(false);
  }
}
