import 'package:flutter/material.dart';
import 'package:football_project/widgets/build_team_logo.dart';

class UpcomingMatchCard extends StatelessWidget {
  const UpcomingMatchCard({
    super.key,
    required this.teamA,
    required this.teamALogo,
    required this.teamB,
    required this.teamBLogo,
    required this.stadium,
    required this.time,
    required this.competition,
    required this.date,
  });

  final String competition;
  final String date;
  final String teamA;
  final String time;
  final String teamALogo;
  final String teamBLogo;
  final String teamB;
  final String stadium;

String getTimeRemaining(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();
  final difference = date.difference(now);

  if (difference.isNegative) {
    return "التاريخ قد مر";
  }

  if (difference.inDays > 0) {
    return "متبقي ${difference.inDays} يوم${difference.inDays > 1 ? '' : ''}";
  } else if (difference.inHours > 0) {
    return "متبقي ${difference.inHours} ساعة${difference.inHours > 1 ? '' : ''}";
  } else if (difference.inMinutes > 0) {
    return "متبقي ${difference.inMinutes} دقيقة${difference.inMinutes > 1 ? '' : ''}";
  } else {
    return "متبقي ثواني";
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4, 
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), 
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  competition=='Primera Division'?'La Liga':competition,
                  style: const TextStyle(color: Colors.white, fontSize: 12), 
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 12), 
                    const SizedBox(width: 2), 
                    Text(
                      date.isNotEmpty ? date.substring(0, 16) : 'تاريخ غير محدد',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      BuildTeamLogo( teamALogo:teamALogo,),
                      const SizedBox(height: 4),
                      Text(
                        teamA,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      time.isNotEmpty ? getTimeRemaining(time) : 'وقت غير محدد',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'لم تبدأ بعد',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 10, 
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      BuildTeamLogo( teamALogo: teamBLogo,),
                      const SizedBox(height: 4),
                      Text(
                        teamB,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, 
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(6), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.grey), 
                const SizedBox(width: 2),
                Text(
                  stadium.isNotEmpty ? stadium : ' غير محدد',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10, 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}