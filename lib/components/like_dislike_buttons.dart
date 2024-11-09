import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';

class LikeDislikeButtons extends StatefulWidget {
  final String categoryId;
  final String canteenId;
  final String stallId;
  final String currentUserId;

  const LikeDislikeButtons({
    Key? key,
    required this.categoryId,
    required this.canteenId,
    required this.stallId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _LikeDislikeButtonsState createState() => _LikeDislikeButtonsState();
}

class _LikeDislikeButtonsState extends State<LikeDislikeButtons> {
  bool like = false;
  bool dislike = false;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }

  void _loadUserVote() async {
    String? vote = await firestoreService.getUserVote(
      widget.categoryId,
      widget.canteenId,
      widget.stallId,
      widget.currentUserId,
    );
    setState(() {
      if (vote == 'thumbsUp') {
        like = true;
        dislike = false;
      } else if (vote == 'thumbsDown') {
        like = false;
        dislike = true;
      } else {
        like = false;
        dislike = false;
      }
    });
  }

  void _handleThumbsUp() async {
    setState(() {
      if (like) {
        like = false;
      } else {
        like = true;
        dislike = false;
      }
    });
    await firestoreService.voteThumbsUp(
      widget.categoryId,
      widget.canteenId,
      widget.stallId,
      widget.currentUserId,
    );
  }

  void _handleThumbsDown() async {
    setState(() {
      if (dislike) {
        dislike = false;
      } else {
        dislike = true;
        like = false;
      }
    });
    await firestoreService.voteThumbsDown(
      widget.categoryId,
      widget.canteenId,
      widget.stallId,
      widget.currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery inside build method
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Menu Heading
        Text(
          "Menu:",
          style: TextStyle(
            fontSize: (25 / height) * height,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 50),
        // Like Button
        GestureDetector(
          onTap: _handleThumbsUp,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/like.svg",
                height: height * 0.04,
                width: width * 0.3,
                color: like ? Colors.green : null,
              ),
              Text(
                "Like",
                style: TextStyle(
                  fontSize: (15 / height) * height,
                  color: like
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: width * 0.1),
        // Dislike Button
        GestureDetector(
          onTap: _handleThumbsDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/dislike.svg",
                height: height * 0.04,
                width: width * 0.3,
                color: dislike ? Colors.red : null,
              ),
              Text(
                "Dislike",
                style: TextStyle(
                  fontSize: (15 / height) * height,
                  color: dislike
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
