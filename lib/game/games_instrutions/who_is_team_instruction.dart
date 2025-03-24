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
                          title: 'كيفية اللعب:',
                          content: '',
                        ),
                        _buildSection(
                            title: '',
                            content:
                                '- ستظهر لك صورة فريق ويجب عليك تخمين أسماء اللاعبين.'),
                        _buildSection(
                          title: '',
                          content: '- لديك 120 ثانية لكل جولة.',
                        ),
                        _buildSection(
                          title: '',
                          content: '- لكل إجابة صحيحة تحصل على نقاط.',
                        ),
                        _buildSection(
                          title: 'قوانين اللعبة:',
                          content: '',
                        ),
                        _buildSection(
                          title: '',
                          content: '- يمكنك ارتكاب 4 أخطاء فقط في كل جولة.',
                        ),
                        _buildSection(
                          title: '',
                          content:
                              '- عند انتهاء الوقت أو عدد الأخطاء، تنتهي الجولة.',
                        ),
                        _buildSection(
                          title: '',
                          content: '- بعد 3 جولات، يتم عرض النتيجة النهائية.',
                        ),
                        
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