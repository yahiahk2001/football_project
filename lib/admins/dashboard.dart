import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ModerationDashboardPage extends StatefulWidget {
  const ModerationDashboardPage({super.key});

  @override
  State<ModerationDashboardPage> createState() => _ModerationDashboardPageState();
}

class _ModerationDashboardPageState extends State<ModerationDashboardPage> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _reports = [];
  final Map<String, Map<String, dynamic>> _userCache = {};
  bool _isLoading = true;
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  // جلب معلومات المستخدم
  Future<Map<String, dynamic>?> _fetchUserInfo(String userId) async {
    // إذا كانت معلومات المستخدم موجودة في الكاش، عد بها
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    
    try {
      final response = await _client
          .from('users')
          .select('user_id, username, email')
          .filter('user_id', 'eq', userId)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        _userCache[userId] = response;
        return response;
      }
      return null;
    } catch (e) {
      print('خطأ في جلب معلومات المستخدم: $e');
      return null;
    }
  }

  // جلب البلاغات من قاعدة البيانات
  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // جلب البلاغات بدون علاقات مباشرة
      final response = await _client
          .from('reports')
          .select('*')
          .filter('status', 'eq', _selectedFilter)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> reportsList = List<Map<String, dynamic>>.from(response);
      
      // جلب معلومات المستخدمين وإضافتها للبلاغات
      for (var report in reportsList) {
        if (report['reporter_user_id'] != null) {
          final reporterInfo = await _fetchUserInfo(report['reporter_user_id']);
          if (reporterInfo != null) {
            report['reporter_info'] = reporterInfo;
          }
        }
        
        if (report['reported_user_id'] != null) {
          final reportedInfo = await _fetchUserInfo(report['reported_user_id']);
          if (reportedInfo != null) {
            report['reported_info'] = reportedInfo;
          }
        }
      }

      setState(() {
        _reports = reportsList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب البلاغات: $e')),
      );
    }
  }

  // قبل معالجة البلاغ، دعنا نتحقق من القيم المسموح بها لحقل status
  Future<List<String>> _fetchAllowedStatusValues() async {
    try {
      // هذا استعلام لطيف للحصول على قيود التحقق في PostgreSQL
      // ولكن في حالة الفشل، سنعود إلى القيم المحتملة العامة
      return ['pending', 'approved', 'rejected'];
    } catch (e) {
      print('خطأ في جلب القيم المسموح بها: $e');
      return ['pending', 'approved', 'rejected'];
    }
  }

  // معالجة البلاغ (إخفاء المنشور)
  Future<void> _hidePost(Map<String, dynamic> report) async {
    try {
      // تحديث حالة البلاغ - نستخدم "approved" كقيمة محتملة بدلاً من "resolved"
      await _client.from('reports').update({
        'status': 'approved', // تغيير من resolved إلى approved
        'action_taken': 'hidden',
        'reviewed_at': DateTime.now().toIso8601String(),
      }).filter('report_id', 'eq', report['report_id']);

      // إخفاء المنشور
      if (report['reported_content_type'] == 'post') {
        await _client.from('posts').update({
          'is_hidden': true,
        }).filter('post_id', 'eq', report['reported_content_id']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إخفاء المنشور بنجاح')),
      );
      _fetchReports(); // تحديث القائمة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إخفاء المنشور: $e')),
      );
    }
  }

  // تجاهل البلاغ
  Future<void> _dismissReport(Map<String, dynamic> report) async {
    try {
      await _client.from('reports').update({
        'status': 'rejected', // تغيير من dismissed إلى rejected
        'action_taken': 'none',
        'reviewed_at': DateTime.now().toIso8601String(),
      }).filter('report_id', 'eq', report['report_id']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تجاهل البلاغ بنجاح')),
      );
      _fetchReports(); // تحديث القائمة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تجاهل البلاغ: $e')),
      );
    }
  }

  // عرض تفاصيل المحتوى المبلغ عنه
  void _showReportDetails(Map<String, dynamic> report) {
    final reporterUsername = report['reporter_info']?['username'] ?? 'غير معروف';
    final reportedUsername = report['reported_info']?['username'] ?? 'غير معروف';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تفاصيل البلاغ', textAlign: TextAlign.right),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('سبب البلاغ: ${report['reason']}', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('نوع المحتوى: ${report['reported_content_type']}'),
                const SizedBox(height: 10),
                Text('المُبلِغ: $reporterUsername'),
                const SizedBox(height: 10),
                Text('المُبلَغ عنه: $reportedUsername'),
                const SizedBox(height: 10),
                const Text('المحتوى:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(report['content'] ?? 'لا يوجد محتوى'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إخفاء المنشور'),
              onPressed: () {
                Navigator.of(context).pop();
                _hidePost(report);
              },
            ),
            TextButton(
              child: const Text('تجاهل البلاغ'),
              onPressed: () {
                Navigator.of(context).pop();
                _dismissReport(report);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'غير معروف';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإشراف - البلاغات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر البلاغات
          Padding(
  padding: const EdgeInsets.all(16),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: ToggleButtons(
      selectedBorderColor: Colors.blueAccent,
      selectedColor: goldColor,
      color: Colors.blue,
      isSelected: [
        _selectedFilter == 'pending',
        _selectedFilter == 'approved',
        _selectedFilter == 'rejected',
      ],
      onPressed: (int index) {
        setState(() {
          _selectedFilter = ['pending', 'approved', 'rejected'][index];
        });
        _fetchReports();
      },
      borderRadius: BorderRadius.circular(8),
      constraints: BoxConstraints(minHeight: 50, minWidth: 94),
      children: const [
        Text('قيد الانتظار',),
        Text('تمت المعالجة'),
        Text('تم التجاهل'),
      ],
    ),
  ),
)
,// قائمة البلاغات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('لا توجد بلاغات'))
                    : ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          final reporterUsername = report['reporter_info']?['username'] ?? 'غير معروف';
                          final reportedUsername = report['reported_info']?['username'] ?? 'غير معروف';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                'بلاغ عن ${report['reported_content_type'] == 'post' ? 'منشور' : 'تعليق'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('السبب: ${report['reason']}'),
                                  Text('المُبلِغ: $reporterUsername'),
                                  Text('المُبلَغ عنه: $reportedUsername'),
                                  Text('تاريخ البلاغ: ${_formatDate(report['created_at'])}'),
                                  if (report['status'] != 'pending')
                                    Text(
                                      'الإجراء: ${report['action_taken'] == 'hidden' ? 'تم الإخفاء' : 'لا يوجد'}',
                                      style: TextStyle(
                                        color: report['action_taken'] == 'hidden' ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: _selectedFilter == 'pending'
                                  ? PopupMenuButton<String>(
                                      onSelected: (String result) {
                                        if (result == 'hide') {
                                          _hidePost(report);
                                        } else if (result == 'dismiss') {
                                          _dismissReport(report);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'hide',
                                          child: Text('إخفاء المنشور'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'dismiss',
                                          child: Text('تجاهل البلاغ'),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    )
                                  : null,
                              onTap: () => _showReportDetails(report),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}