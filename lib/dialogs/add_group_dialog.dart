import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddGroupDialog extends StatefulWidget {
  final Function(String, String) onSave;

  AddGroupDialog({required this.onSave});

  @override
  _AddGroupDialogState createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _selectedIconPath;

  final Map<String, String> iconMap = {
    'assets/images/1.png': 'assets/images/language.png',
    'assets/images/2.png': 'assets/images/music.png',
    'assets/images/3.png': 'assets/images/education.png',
    'assets/images/4.png': 'assets/images/social.png',
    'assets/images/5.png': 'assets/images/writing.png',
    'assets/images/6.png': 'assets/images/sport.png',
    'assets/images/7.png': 'assets/images/code.png',
    'assets/images/8.png': 'assets/images/art.png',
    'assets/images/9.png': 'assets/images/hobbies.png',
    'assets/images/10.png': 'assets/images/digital.png',
    'assets/images/11.png': 'assets/images/color.png',
    'assets/images/12.png': 'assets/images/atom.png',
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.r),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add new group',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: Color(0xFF000000),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 25.r),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h, color: Color(0xFFC6C8CC)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFEFEFF0),
                  hintText: 'Name of the new group',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.r),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.edit_outlined, size: 20.r),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.h,
                    horizontal: 10.w,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 45.w,
                    minHeight: 45.h,
                  ),
                  hintStyle: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Color(0xFF3C3C43).withOpacity(0.6),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                'Choose icon',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: Color(0xFF777F89),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: iconMap.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 4.h,
                ),
                itemBuilder: (context, index) {
                  String iconPath = iconMap.keys.elementAt(index);
                  bool isSelected = _selectedIconPath == iconMap[iconPath];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIconPath = iconMap[iconPath];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF2963E8)
                              : Colors.transparent,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Image.asset(
                        isSelected ? iconMap[iconPath]! : iconPath,
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                child: ElevatedButton(
                  onPressed: () {
                    if (_groupNameController.text.isNotEmpty &&
                        _selectedIconPath != null) {
                      widget.onSave(
                          _groupNameController.text, _selectedIconPath!);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill out all fields'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2963E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.w, vertical: 5.h),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
