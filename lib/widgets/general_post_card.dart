
import 'package:flutter/material.dart';
import 'package:football_project/consts.dart';
import 'package:football_project/widgets/post_card_image.dart';
import 'package:football_project/widgets/post_card_title.dart';

class GeneralNewsCard extends StatelessWidget {
 final String title;
  final String image;
  final String author;
  final String timeAgo;

  const GeneralNewsCard({
    super.key,
    required this.title,
    required this.image,
    required this.author,
    required this.timeAgo, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Theme.of(context).brightness == Brightness.dark 
    ?  primaryColor.withOpacity(0.3) // لون في الوضع المظلم
    : Colors.white70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeneralPostCardHeader(author: author, timeAgo: timeAgo,),
          PostCardTitle(title: title),
          PostCardImage(imageUrl: image),
        ],
      ),
    );
  }
}


// ignore: must_be_immutable
class GeneralPostCardHeader extends StatelessWidget {
  final String author;
  final String timeAgo;
  String? authorImage;

   GeneralPostCardHeader({
    super.key,
    required this.author,
    required this.timeAgo, this.authorImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(authorImage??'https://www.ahlamak.net/f/res/h37/dream-phrases/000/013/30/0001330-487-ahlamak-1cc825172ca240099db63efa70ffcbee-r00.jpg'
                ,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author,
                  style: const TextStyle(
                      
                      fontSize: 12)),
              Text(timeAgo,
                  style: const TextStyle(
                      fontSize: 8)),
            ],
          ),
          
        ],
      ),
    );
  }
}

