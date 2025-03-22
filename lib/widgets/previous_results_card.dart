import 'package:flutter/material.dart';
import 'package:football_project/widgets/build_team_logo.dart';
import 'package:timeago/timeago.dart' as timeago;

class PreviousResultsCard extends StatelessWidget {
  const PreviousResultsCard({
    super.key, 
    required this.teamA,
    required this.teamALogo,
    required this.scoreA,
    required this.teamB,
    required this.teamBLogo,
    required this.scoreB,
    required this.competition,
    required this.date,
  });

  final String teamA;
  final String teamALogo;
  final String scoreA;
  final String teamB;
  final String teamBLogo;
  final String scoreB;
  final String competition;
  final String date;

String getTimeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    return timeago.format(date, locale: 'ar'); // تحويل التاريخ
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
              color: Colors.green[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  competition=='Primera Division'?'La Liga':competition,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Text(
                  "انتهت المباراة",
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
                      BuildTeamLogo( teamALogo: teamALogo,),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        scoreA,
                        style: const TextStyle(
                                                    color: Colors.black,

                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4), 
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        scoreB,
                        style: const TextStyle(
                                                    color: Colors.black,

                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      BuildTeamLogo( teamALogo:teamBLogo,),
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
                const Icon(Icons.date_range, size: 12, color: Colors.grey), 
                const SizedBox(width: 2),
                Text(
                  date.isNotEmpty ? getTimeAgo(date): ' غير معلوم',
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
