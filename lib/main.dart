import 'package:flutter/material.dart';
import 'package:football_project/pages/home_page.dart';
import 'package:football_project/pages/login_page.dart';
import 'package:football_project/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://beralpqnpvxamwexcplb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJlcmFscHFucHZ4YW13ZXhjcGxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5MDEyNzksImV4cCI6MjA1MDQ3NzI3OX0.om8205XhAgFhnZ8zzEOq8woHlRDGz7pc0JGH9Jd_XLw',
  );

  // تشغيل التطبيق
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FootballZone(),
    ),
  );
}

class FootballZone extends StatelessWidget {
  const FootballZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'SA'),
          home: const AuthRedirect(),
        );
      },
    );
  }
}

class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // التوجيه بناءً على حالة المستخدم
    if (session != null) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}



const Color lightTextColor = Color(0xFF95A5A6);
const Color primaryColor = Color(0xFF1A2A3A);
const Color accentColor = Color(0xFF4CAF50);
const Color textColor = Color(0xFFF5F5F5);
const Color goldColor = Color(0xFFFFD700);
const Color alertColor = Color(0xFFFF4136);

class AppColors {
  static const Color primary =
      Color(0xFF0D1B2A); // اللون الأساسي (أزرق غامق للترويسات والأجزاء البارزة)
  static const Color secondary = Color(
      0xFF1B263B); // اللون الثانوي (أزرق داكن أقل حدة للنصوص والخلفيات الفرعية)
  static const Color accent =
      Color(0xFFF4A261); // لون مساعد (برتقالي مشرق للتفاصيل أو الحدود البارزة)
  static const Color background =
      Color(0xFF0A1128); // لون الخلفية العام (غامق جدًا مع لمسة زرقاء)
  static const Color surface =
      Color(0xFF415A77); // لون السطح (أزرق رمادي للأجزاء السطحية مثل البطاقات)
static const Color button = Color.fromARGB(255, 4, 1, 85); // أحمر عميق ومشرق.
 // لون الأزرار الأساسي (يتماشى مع الألوان الغامقة)
  static const Color text = Color(
      0xFFD9E2EC); // لون النصوص (أبيض مزرق ناعم ليتباين مع الخلفية الداكنة) // لون النصوص (داكن للقراءة السهلة)
}
