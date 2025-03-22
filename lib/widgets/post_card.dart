import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/models/post_model.dart';
import 'package:football_project/widgets/post_card_footer.dart';
import 'package:football_project/widgets/post_card_header.dart';
import 'package:football_project/widgets/post_card_image.dart';
import 'package:football_project/widgets/post_card_title.dart';

class NewsCard extends StatelessWidget {
  final ReporterPost post;


  const NewsCard({
    super.key,
   required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: Theme.of(context).brightness == Brightness.dark 
    ?  primaryColor.withOpacity(0.3) // لون في الوضع المظلم
    : Colors.white54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostCardHeader( post: post,),
          PostCardTitle(title: post.content.isNotEmpty ? post.content : ' '),
         post.image != null && post.image!.isNotEmpty ? PostCardImage(imageUrl: post.image!) : Container(),
          PostCardFooter(post: post,),
        ],
      ),
    );
  }
}
