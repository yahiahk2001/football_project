import 'package:flutter/material.dart';

class PostCardTitle extends StatefulWidget {
  final String title;

  const PostCardTitle({super.key, required this.title});

  @override
  _PostCardTitleState createState() => _PostCardTitleState();
}

class _PostCardTitleState extends State<PostCardTitle> {
  bool isExpanded = false;

  bool isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection:
                isArabic(widget.title) ? TextDirection.rtl : TextDirection.ltr,
            child: Align(
              alignment: isArabic(widget.title)
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: SelectableText(
                
                widget.title,
                textAlign:
                    isArabic(widget.title) ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'NotoKufiArabic-Bold',
                ),
                maxLines: isExpanded ? null : 2,
              ),
            ),
          ),
          if (widget.title.length > 100) // عرض زر "عرض المزيد/أقل" فقط عند الحاجة
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Align(
                alignment: isArabic(widget.title)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  isExpanded ? 'عرض أقل' : 'عرض المزيد',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
