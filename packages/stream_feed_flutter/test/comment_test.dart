import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_feed_flutter/src/widgets/comment/field.dart';
import 'package:stream_feed_flutter/src/widgets/comment/item.dart';
import 'package:stream_feed_flutter/src/widgets/comment/textarea.dart';
import 'package:stream_feed_flutter/src/widgets/dialogs/dialogs.dart';
import 'package:stream_feed_flutter/src/widgets/user/avatar.dart';
import 'package:stream_feed_flutter/stream_feed_flutter.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import 'package:mocktail/mocktail.dart';

import 'mock.dart';

main() {
  testWidgets('CommentItem', (tester) async {
    await mockNetworkImages(() async {
      var pressedHashtags = <String?>[];
      var pressedMentions = <String?>[];

      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
        body: CommentItem(
          user: User(data: {
            'name': 'Rosemary',
            'subtitle': 'likes playing fresbee in the park',
            'profile_image': 'https://randomuser.me/api/portraits/women/20.jpg',
          }),
          reaction: Reaction(
            createdAt: DateTime.now(),
            kind: 'comment',
            data: {
              'text': 'Snowboarding is awesome! #snowboarding #winter @sacha',
            },
          ),
          onMentionTap: (String? mention) {
            pressedMentions.add(mention);
          },
          onHashtagTap: (String? hashtag) {
            pressedHashtags.add(hashtag);
          },
        ),
      )));

      final avatar = find.byType(Avatar);

      expect(avatar, findsOneWidget);
      final richtexts = tester.widgetList<Text>(find.byType(Text));

      expect(richtexts.toList().map((e) => e.data), [
        'Rosemary',
        'a moment ago',
        'Snowboarding ',
        'is ',
        'awesome! ',
        ' #snowboarding',
        ' #winter',
        ' @sacha',
      ]);
      expect(richtexts.toList().map((e) => e.style), [
        TextStyle(
            inherit: true,
            color: Color(0xff0ba8e0),
            fontSize: 14.0,
            fontWeight: FontWeight.w700),
        TextStyle(
            inherit: true,
            color: Color(0xff7a8287),
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            height: 1.5),
        TextStyle(inherit: true, color: Color(0xff000000), fontSize: 14.0),
        TextStyle(inherit: true, color: Color(0xff000000), fontSize: 14.0),
        TextStyle(inherit: true, color: Color(0xff000000), fontSize: 14.0),
        TextStyle(inherit: true, color: Color(0xff0076ff), fontSize: 14.0),
        TextStyle(inherit: true, color: Color(0xff0076ff), fontSize: 14.0),
        TextStyle(inherit: true, color: Color(0xff0076ff), fontSize: 14.0)
      ]);

      await tester.tap(find.widgetWithText(InkWell, ' #winter').first);
      await tester.tap(find.widgetWithText(InkWell, ' @sacha').first);
      expect(pressedHashtags, ['winter']);
      expect(pressedMentions, ['sacha']);
    });
  });

  testWidgets('CommentField', (WidgetTester tester) async {
    final key = GlobalKey();
    final mockClient = MockStreamFeedClient();
    final mockReactions = MockReactions();
    final mockStreamAnalytics = MockStreamAnalytics();
    when(() => mockClient.reactions).thenReturn(mockReactions);
    const foreignId = 'like:300';
    const activityId = 'activityId';
    const feedGroup = 'whatever:300';
    const kind = 'comment';
    const textInput = 'Soup';
    const reaction = Reaction(
      kind: kind,
      activityId: activityId,
      data: {'text': textInput},
    );
    final activity = EnrichedActivity(id: activityId, foreignId: foreignId);
    const label = kind;
    final engagement = Engagement(
        content: Content(foreignId: FeedId.fromId(activity.foreignId)),
        label: label,
        feedId: FeedId.fromId(feedGroup));

    when(() => mockReactions.add(
          kind,
          activityId,
          data: {'text': textInput},
        )).thenAnswer((_) async => reaction);

    when(() => mockStreamAnalytics.trackEngagement(engagement))
        .thenAnswer((_) async => Future.value());
    final textEditingController = TextEditingController();

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: StreamFeedCore(
        analyticsClient: mockStreamAnalytics,
        client: mockClient,
        child: CommentField(
          statusUpdateFormController: StatusUpdateFormController(ImagePicker()),
          key: key,
          feedGroup: feedGroup,
          activity: activity,
          textEditingController: textEditingController,
        ),
      ),
    )));

    final avatar = find.byType(Avatar);
    final textArea = find.byType(TextArea);
    final button = find.byType(ElevatedButton);
    expect(avatar, findsOneWidget);
    expect(textArea, findsOneWidget);
    // expect(button, findsOneWidget);
    await tester.enterText(textArea, textInput);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    tester.widget<EditableText>(find.text(textInput));

    // final commentFieldState = key.currentState! as CommentFieldState;
    expect(textEditingController.value.text, textInput);

    await tester.tap(button);
    verify(() => mockClient.reactions.add(kind, activityId)).called(1);
    verify(() => mockStreamAnalytics.trackEngagement(engagement)).called(1);
  });

  testWidgets('TextArea', (WidgetTester tester) async {
    final textController = TextEditingController();
    final focusNode = FocusNode();
    final hintStyle = TextStyle(
      inherit: false,
      color: Colors.pink[500],
      fontSize: 10.0,
    );
    final inputTextStyle = TextStyle(
      inherit: false,
      color: Colors.green[500],
      fontSize: 12.0,
      textBaseline: TextBaseline.alphabetic,
    );
    var _value = '';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextArea(
          textEditingController: textController,
          focusNode: focusNode,
          hintText: 'Placeholder',
          hintTextStyle: hintStyle,
          inputTextStyle: inputTextStyle,
          onSubmitted: (String value) {
            _value = value;
          },
        ),
      ),
    ));

    final textFieldWidget = find.byType(TextField);
    await tester.enterText(textFieldWidget, 'Soup');
    expect(focusNode.hasPrimaryFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_value, 'Soup');
    final inputText = tester.widget<EditableText>(find.text('Soup'));
    expect(inputText.style, inputTextStyle);
    expect(focusNode.hasPrimaryFocus, isFalse);
    final hintText = tester.widget<Text>(find.text('Placeholder'));
    expect(hintText.style, hintStyle);
  });
}
