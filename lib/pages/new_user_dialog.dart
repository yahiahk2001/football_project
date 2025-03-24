import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewUserDialog {
  // استخدام معرف المستخدم كجزء من مفتاح التخزين
  static String _getFirstLoginKey(String userId) {
    return 'is_first_login_$userId';
  }

  // التحقق مما إذا كان المستخدم جديدًا (باستخدام معرف المستخدم)
  static Future<bool> isNewUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getFirstLoginKey(userId)) ?? true; // إذا لم يتم العثور على القيمة، فهذا يعني أنه مستخدم جديد
  }

  // تحديث حالة المستخدم بعد تسجيل الدخول الأول (باستخدام معرف المستخدم)
  static Future<void> markUserAsExisting(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getFirstLoginKey(userId), false);
  }

  // عرض نافذة الحوار للمستخدم الجديد
  static Future<bool> showProfileCompletionDialog(BuildContext context, String userId) async {
    bool isNew = await isNewUser(userId);
    
    if (isNew) {
      bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  backgroundColor: Colors.white,
  title: Row(
    children: [
      Icon(Icons.person, color: Color(0xFF4CAF50)), // أيقونة جذابة
      SizedBox(width: 8),
      Text(
        'إكمال الملف الشخصي',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2A3A),
        ),
      ),
    ],
  ),
  content: Text(
    'هل ترغب في إضافة صورة البروفايل ومعلوماتك الشخصية الآن؟',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
  ),
  actionsAlignment: MainAxisAlignment.spaceAround,
  actions: [
    TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFF95A5A6),
      ),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
      child: Text('لاحقاً', style: TextStyle(fontSize: 16)),
    ),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
      child: Text('إكمال الآن', style: TextStyle(fontSize: 16, color: Colors.white)),
    ),
  ],
);

        },
      );
      
      // تحديث حالة المستخدم بعد عرض الحوار
      await markUserAsExisting(userId);
      
      return result ?? false;
    }
    
    return false; // لا يحتاج للذهاب إلى صفحة الملف الشخصي لأنه ليس مستخدمًا جديدًا
  }
}