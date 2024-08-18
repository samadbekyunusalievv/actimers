import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main_screen.dart';
import 'premium_status_helper.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _navigateToMainScreen();
  }

  Future<void> _checkPremiumStatus() async {
    isPremium = await PremiumStatusHelper.getPremiumStatus();
    setState(() {});
  }

  void _navigateToMainScreen() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF627FC0), Color(0xFF173782)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 70.w,
              height: 70.h,
            ),
            SizedBox(height: 14.h),
            Text(
              'ACTIMERS',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 40.sp,
                  height: 1.2.h,
                  color: Colors.white,
                ),
              ),
            ),
            if (isPremium) ...[
              SizedBox(height: 14.h),
              Text(
                'Premium',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w200,
                  fontSize: 28.sp,
                  height: 1.h,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
