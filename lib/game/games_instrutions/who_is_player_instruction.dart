import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'تعليمات اللعبة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSection(
                          title: 'كيف تلعب؟',
                          content:
                              'في كل جولة، ستواجه 5 تحديات عشوائية. في كل تحدٍ، عليك تخمين اسم لاعب كرة القدم من خلال التلميحات المقدمة.',
                        ),

                        _buildSection(
                          title: 'نظام النقاط',
                          content:
                              '''كلما قل عدد التلميحات التي تحتاجها، زادت النقاط التي تحصل عليها:
• تخمين صحيح من أول تلميح: 50 نقطة
• تخمين صحيح من ثاني تلميح: 40 نقطة
• تخمين صحيح من ثالث تلميح: 30 نقطة
• تخمين صحيح من رابع تلميح: 20 نقطة
• تخمين صحيح من آخر تلميح: 10 نقاط''',
                        ),

                        _buildSection(
                          title: 'التلميحات',
                          content:
                              'لديك 5 تلميحات لكل لاعب. يمكنك طلب تلميح جديد في أي وقت، لكن تذكر أن النقاط تقل مع كل تلميح إضافي.',
                        ),

                        _buildSection(
                          title: 'الإجابات المقبولة',
                          content:
                              'يمكنك كتابة اسم اللاعب بعدة صيغ مقبولة. على سبيل المثال: "ميسي"، "ليو ميسي"، "ليونيل ميسي".',
                        ),

                        _buildSection(
                          title: 'نهاية اللعبة',
                          content:
                              'تنتهي اللعبة في إحدى الحالتين:\n• إكمال جميع التحديات الخمسة بنجاح\n• استنفاد جميع التلميحات في تحدٍ واحد دون تخمين صحيح',
                        ),

                        // Start Game Button
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

