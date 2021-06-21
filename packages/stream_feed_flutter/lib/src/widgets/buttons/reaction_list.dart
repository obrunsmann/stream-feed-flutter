import 'package:flutter/material.dart';
import 'package:stream_feed_flutter/src/utils/typedefs.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import '../comment/comment_item.dart';

class ReactionList extends StatelessWidget {
  final List<Reaction> reactions;
  final bool? reverse;
  final OnReactionTap? onReactionTap;
  final OnHashtagTap? onHashtagTap;
  final OnMentionTap? onMentionTap;
  final OnUserTap? onUserTap;

  const ReactionList({
    Key? key,
    required this.reactions,
    this.reverse,
    this.onReactionTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      //TODO: extract this into core
      reverse: reverse ?? false,
      itemCount: reactions.length,
      itemBuilder: (context, idx) => CommentItem(
        user: reactions[idx].user,
        reaction: reactions[idx],
        onReactionTap: onReactionTap,
        onHashtagTap: onHashtagTap,
        onMentionTap: onMentionTap,
        onUserTap: onUserTap,
      ),
    );
  }

  // getUser(String? userId) {}
}