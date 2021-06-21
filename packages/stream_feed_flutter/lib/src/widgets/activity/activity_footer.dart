import 'package:flutter/material.dart';
import 'package:stream_feed_flutter/src/widgets/buttons/buttons.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

class ActivityFooter extends StatelessWidget {
  const ActivityFooter({required this.activity, this.feedGroup = 'user'});
  final EnrichedActivity activity;
  final String feedGroup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PostButton(activity: activity, feedGroup: feedGroup),
          RepostButton(activity: activity),
          LikeButton(activity: activity),
        ],
      ),
    );
  }
}