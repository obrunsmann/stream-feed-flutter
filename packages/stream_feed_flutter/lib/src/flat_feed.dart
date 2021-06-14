import 'package:flutter/material.dart';
import 'package:stream_feed_flutter/src/activity.dart';
import 'package:stream_feed_flutter/src/typedefs.dart';
import 'package:stream_feed_flutter/stream_feed_flutter.dart';

class FlatFeed extends StatelessWidget {
  const FlatFeed({Key? key, required this.slug}) : super(key: key);
  final String slug;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StreamFeedCore.of(context).getEnrichedActivities(slug: slug),
        builder: (BuildContext context,
            AsyncSnapshot<List<EnrichedActivity>> snapshot) {
          if (snapshot.hasData) {
            return FlatFeedInner(
              activities: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return ErrorStateWidget();
          } else {
            return ProgressStateWidget();
          }
        });
  }
}

class FlatFeedInner extends StatelessWidget {
  const FlatFeedInner({
    Key? key,
    required this.activities,
    this.onHashtagTap,
    this.onMentionTap,
    this.onUserTap,
  }) : super(key: key);

  final OnHashtagTap? onHashtagTap;
  final OnMentionTap? onMentionTap;
  final OnUserTap? onUserTap;
  final List<EnrichedActivity> activities;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, idx) => StreamFeedActivity(
        activity: activities[idx],
        onHashtagTap: onHashtagTap,
        onMentionTap: onMentionTap,
        onUserTap: onUserTap,
      ),
    );
  }
}

//TODO: improve this
class ErrorStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.announcement,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            'Sorry an error occured',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

//TODO: improve this
class ProgressStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
