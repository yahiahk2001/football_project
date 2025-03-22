import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  _StandingsPageState createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  final String apiKey = '485a87aafb3c4b8f91bb8b34ac58fb65';
  final String baseUrl = 'https://api.football-data.org/v4';

  bool isLoading = true;
  Map<String, dynamic>? standingsData;
  String selectedCompetition = 'PD'; // Premier League as default
  String selectedSeason = '2024'; // Current season as default

  List<Map<String, dynamic>> competitions = [
    {'id': 'PL', 'name': 'الدوري الإنجليزي'},
    {'id': 'BL1', 'name': 'الدوري الألماني'},
    {'id': 'SA', 'name': 'الدوري الإيطالي'},
    {'id': 'PD', 'name': 'الدوري الإسباني'},
    {'id': 'FL1', 'name': 'الدوري الفرنسي'},
  ];

  List<String> seasons = [
    '2024',
    '2023',
  ];

  @override
  void initState() {
    super.initState();
    _loadCachedStandings();
  }

  Future<void> _loadCachedStandings() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData =
        prefs.getString('standings_${selectedCompetition}_$selectedSeason');

    if (cachedData != null) {
      setState(() {
        standingsData = jsonDecode(cachedData);
        isLoading = false;
      });
    } else {
      fetchStandings();
    }
  }

  Future<void> fetchStandings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
          '$baseUrl/competitions/$selectedCompetition/standings?season=$selectedSeason');
      final headers = {
        'X-Auth-Token': apiKey,
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cache the data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'standings_${selectedCompetition}_$selectedSeason', response.body);

        setState(() {
          standingsData = data;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل بيانات الترتيب: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'البطولة',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCompetition,
                    items: competitions.map<DropdownMenuItem<String>>((comp) {
                      return DropdownMenuItem<String>(
                        value: comp['id'],
                        child: Text(comp['name'],
                            style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCompetition = value!;
                      });
                      _loadCachedStandings();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'الموسم',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSeason,
                    items: seasons.map((season) {
                      return DropdownMenuItem(
                        value: season,
                        child: Text(season),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSeason = value!;
                      });
                      _loadCachedStandings();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: accentColor))
                : standingsData == null
                    ? const Center(child: Text('لا توجد بيانات متاحة'))
                    : buildStandingsTable(),
          ),
        ],
      ),
    );
  }

  Widget buildStandingsTable() {
    final standings = standingsData!['standings'] as List;
    final table = standings.first['table'] as List;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                standingsData!['competition']['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                // تحديد ما إذا كانت الشاشة صغيرة أم لا
                final isSmallScreen = constraints.maxWidth < 600;
                final isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;

                // تحديد العرض الأمثل - استخدام كامل العرض المتاح
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    // استخدام أقصى عرض متاح أو عرض ثابت إذا كانت الشاشة كبيرة أو في الوضع الأفقي
                    width: isLandscape || !isSmallScreen
                        ? null
                        : constraints.maxWidth * 1.5,
                    child: DataTable(
                      columnSpacing: isSmallScreen ? 4 : 8,
                      horizontalMargin: isSmallScreen ? 6 : 12,
                      headingRowColor: WidgetStateProperty.all(Colors.black54),
                      // استخدام كل الأعمدة دائمًا، ولكن تعديل نمط العرض
                      columns: const [
                        DataColumn(
                            label: Text('#',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('الفريق',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('نقاط',
                                style: TextStyle(
                                    color: Colors
                                        .white))), // تم تغيير "م" إلى "نقاط"
                        DataColumn(
                            label: Text('ف',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'الفوز'),
                        DataColumn(
                            label: Text('ت',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'التعادل'),
                        DataColumn(
                            label: Text('خ',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'الخسارة'),
                        DataColumn(
                            label: Text('له',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'الأهداف المسجلة'),
                        DataColumn(
                            label: Text('عليه',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'الأهداف المستقبلة'),
                        DataColumn(
                            label: Text('±',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'فارق الأهداف'),
                        DataColumn(
                            label: Text('م',
                                style: TextStyle(color: Colors.white)),
                            tooltip: 'المباريات'), // تم تغيير "نقاط" إلى "م"
                      ],
                      rows: table.map<DataRow>((team) {
                        final position = team['position'];
                        final teamName = team['team']['name'];
                        final teamImage = team['team']['crest'];

                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            // إضافة ألوان للمراكز المؤهلة والهبوط
                            if (position <= 4 && selectedCompetition != 'CL') {
                              return Colors.green
                                  .withOpacity(0.2); // مراكز دوري الأبطال
                            } else if (position >= table.length - 3 &&
                                selectedCompetition != 'CL') {
                              return Colors.red
                                  .withOpacity(0.2); // مراكز الهبوط
                            }
                            return null;
                          }),
                          cells: [
                            DataCell(Text('$position')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (teamImage != null && teamImage.isNotEmpty)
                                    Image.network(
                                      teamImage,
                                      width: 20,
                                      height: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.sports_soccer,
                                                  size: 20),
                                    ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      teamName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 11 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              // تم تغيير قيمة المباريات إلى النقاط
                              Text(
                                '${team['points']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 11 : 14,
                                ),
                              ),
                            ),
                            DataCell(Text('${team['won']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['draw']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['lost']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['goalsFor']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['goalsAgainst']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['goalDifference']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                            DataCell(Text('${team['playedGames']}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 14))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8.0),
                    child: const Text(
                      'لرؤية المزيد من المعلومات مرر يميناً او قم بتدوير الجهاز إلى الوضع الأفقي',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
