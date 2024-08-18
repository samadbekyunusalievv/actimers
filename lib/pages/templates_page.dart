import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/premium_bottom_sheet.dart';

class TemplatesPage extends StatelessWidget {
  final Function(String, int, int, int, String, String) onAddTimer;

  TemplatesPage({required this.onAddTimer});

  final Map<String, List<Map<String, dynamic>>> templates = {
    'Languages': [
      {'name': 'German', 'hours': 900, 'icon': 'assets/images/language.png'},
      {'name': 'Spanish', 'hours': 650, 'icon': 'assets/images/language.png'},
      {'name': 'French', 'hours': 750, 'icon': 'assets/images/language.png'},
      {'name': 'Chinese', 'hours': 2300, 'icon': 'assets/images/language.png'},
      {'name': 'Japanese', 'hours': 2300, 'icon': 'assets/images/language.png'},
      {'name': 'Italian', 'hours': 700, 'icon': 'assets/images/language.png'},
      {'name': 'Russian', 'hours': 1100, 'icon': 'assets/images/language.png'},
    ],
    'Programming': [
      {'name': 'Python', 'hours': 350, 'icon': 'assets/images/code.png'},
      {'name': 'JavaScript', 'hours': 350, 'icon': 'assets/images/code.png'},
      {'name': 'Java', 'hours': 450, 'icon': 'assets/images/code.png'},
      {'name': 'C++', 'hours': 450, 'icon': 'assets/images/code.png'},
      {'name': 'HTML and CSS', 'hours': 150, 'icon': 'assets/images/code.png'},
      {'name': 'SQL', 'hours': 150, 'icon': 'assets/images/code.png'},
      {'name': 'Swift', 'hours': 350, 'icon': 'assets/images/code.png'},
      {'name': 'PHP', 'hours': 350, 'icon': 'assets/images/code.png'},
      {'name': 'R', 'hours': 250, 'icon': 'assets/images/code.png'},
    ],
    'Music': [
      {
        'name': 'Guitar playing',
        'hours': 1200,
        'icon': 'assets/images/music.png'
      },
      {
        'name': 'Piano playing',
        'hours': 1750,
        'icon': 'assets/images/music.png'
      },
      {
        'name': 'Violin playing',
        'hours': 2200,
        'icon': 'assets/images/music.png'
      },
      {
        'name': 'Vocal training',
        'hours': 750,
        'icon': 'assets/images/music.png'
      },
      {'name': 'Music theory', 'hours': 250, 'icon': 'assets/images/music.png'},
      {
        'name': 'Drum playing',
        'hours': 1200,
        'icon': 'assets/images/music.png'
      },
      {
        'name': 'Saxophone playing',
        'hours': 1200,
        'icon': 'assets/images/music.png'
      },
      {
        'name': 'Musical improvisation',
        'hours': 750,
        'icon': 'assets/images/music.png'
      },
    ],
    'Art': [
      {'name': 'Drawing', 'hours': 1200, 'icon': 'assets/images/art.png'},
      {'name': 'Oil painting', 'hours': 1200, 'icon': 'assets/images/art.png'},
      {'name': 'Sculpture', 'hours': 1200, 'icon': 'assets/images/art.png'},
      {'name': 'Graphic design', 'hours': 700, 'icon': 'assets/images/art.png'},
      {'name': 'Photography', 'hours': 500, 'icon': 'assets/images/art.png'},
      {
        'name': 'Watercolor painting',
        'hours': 600,
        'icon': 'assets/images/art.png'
      },
      {'name': 'Calligraphy', 'hours': 500, 'icon': 'assets/images/art.png'},
      {'name': 'Animation', 'hours': 900, 'icon': 'assets/images/art.png'},
    ],
    'Education and Professional Skills': [
      {
        'name': 'Public speaking',
        'hours': 150,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Leadership and management',
        'hours': 200,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Financial literacy',
        'hours': 100,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Marketing and advertising',
        'hours': 250,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'UX/UI design',
        'hours': 300,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Accounting',
        'hours': 200,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Data analytics',
        'hours': 250,
        'icon': 'assets/images/education.png'
      },
      {
        'name': 'Sales and negotiation',
        'hours': 200,
        'icon': 'assets/images/education.png'
      },
    ],
    'Personal Hobbies and Interests': [
      {'name': 'Cooking', 'hours': 150, 'icon': 'assets/images/hobbies.png'},
      {'name': 'Dancing', 'hours': 300, 'icon': 'assets/images/hobbies.png'},
      {'name': 'Gardening', 'hours': 200, 'icon': 'assets/images/hobbies.png'},
      {
        'name': 'Travel and tourism',
        'hours': 100,
        'icon': 'assets/images/hobbies.png'
      },
      {
        'name': 'Handicrafts (knitting, sewing)',
        'hours': 200,
        'icon': 'assets/images/hobbies.png'
      },
      {
        'name': 'Board games',
        'hours': 100,
        'icon': 'assets/images/hobbies.png'
      },
      {
        'name': 'Photojournalism',
        'hours': 250,
        'icon': 'assets/images/hobbies.png'
      },
      {'name': 'Winemaking', 'hours': 150, 'icon': 'assets/images/hobbies.png'},
      {
        'name': 'Interior decorating',
        'hours': 200,
        'icon': 'assets/images/hobbies.png'
      },
    ],
    'Social Skills': [
      {
        'name': 'Emotional intelligence',
        'hours': 150,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Communication and negotiation',
        'hours': 200,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Conflict resolution',
        'hours': 100,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Team building',
        'hours': 150,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Social media and branding',
        'hours': 200,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Active listening skills',
        'hours': 100,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Personal effectiveness',
        'hours': 200,
        'icon': 'assets/images/social.png'
      },
      {
        'name': 'Networking events',
        'hours': 150,
        'icon': 'assets/images/social.png'
      },
    ],
    'Writing and Literature': [
      {
        'name': 'Creative writing',
        'hours': 750,
        'icon': 'assets/images/writing.png'
      },
      {'name': 'Poetry', 'hours': 750, 'icon': 'assets/images/writing.png'},
      {'name': 'Journalism', 'hours': 750, 'icon': 'assets/images/writing.png'},
      {
        'name': 'Technical writing',
        'hours': 400,
        'icon': 'assets/images/writing.png'
      },
    ],
    'Digital Skills': [
      {
        'name': 'Video editing',
        'hours': 400,
        'icon': 'assets/images/digital.png'
      },
      {
        'name': 'Photo editing',
        'hours': 250,
        'icon': 'assets/images/digital.png'
      },
      {
        'name': 'Project management',
        'hours': 400,
        'icon': 'assets/images/digital.png'
      },
      {
        'name': 'Cybersecurity',
        'hours': 750,
        'icon': 'assets/images/digital.png'
      },
      {
        'name': 'Mobile app development',
        'hours': 750,
        'icon': 'assets/images/digital.png'
      },
    ],
  };

  Future<bool> _getPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premiumStatus') ?? false;
  }

  Future<void> _showPremiumDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PremiumBottomSheet(
          onUnlockPremium: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('premiumStatus', true);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: templates.keys.length + 1,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'Remember that these figures are approximate and can vary depending on individual characteristics and learning intensity.',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 16.71 / 14,
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w, bottom: 8.h),
            child: TabBar(
              dividerColor: Color(0xF7F7F7),
              tabAlignment: TabAlignment.start,
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
                ...templates.keys
                    .map((category) => _buildTab(category))
                    .toList(),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  itemCount: templates.values
                      .expand((element) => element)
                      .toList()
                      .length,
                  itemBuilder: (context, index) {
                    final allTemplates =
                        templates.values.expand((element) => element).toList();
                    final template = allTemplates[index];
                    final category = templates.entries
                        .firstWhere((entry) => entry.value.contains(template))
                        .key;
                    return _buildTemplateTile(context, template, category);
                  },
                ),
                ...templates.keys.map((category) {
                  return ListView.builder(
                    itemCount: templates[category]!.length,
                    itemBuilder: (context, index) {
                      final template = templates[category]![index];
                      return _buildTemplateTile(context, template, category);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTemplateTile(
      BuildContext context, Map<String, dynamic> template, String category) {
    return Container(
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
          Row(
            children: [
              Image.asset(
                template['icon'],
                width: 44.r,
                height: 44.r,
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    template['name'],
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 24 / 16,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18.r,
                        color: Color(0xFF777F89),
                      ),
                      SizedBox(
                        width: 3.w,
                      ),
                      Text(
                        '${template['hours'].toString().padLeft(3, '0')}:00:00',
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
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: Colors.green,
              size: 30.r,
            ),
            onPressed: () async {
              final isPremium = await _getPremiumStatus();
              if (isPremium) {
                onAddTimer(
                  template['name'],
                  template['hours'],
                  0,
                  0,
                  category,
                  template['icon'],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${template['name']} added to $category group!',
                    ),
                  ),
                );
              } else {
                await _showPremiumDialog(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
