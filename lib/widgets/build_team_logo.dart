import 'package:flutter/material.dart';


class BuildTeamLogo extends StatelessWidget {
  final String teamALogo;

  const BuildTeamLogo(  {super.key, required this.teamALogo});





  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[200],
      child: 
               Image.network(teamALogo, fit: BoxFit.cover)
            
    );
  }
}
