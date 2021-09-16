import 'package:flutter_test/flutter_test.dart';
import 'package:stream_feed_flutter/stream_feed_flutter.dart';

void main() {
  test('mediaType works on all file formats', () {
    final urls = [
      'https://someurl.com/images/test.jpeg',
      'https://someurl.com/images/test.jpg',
      'https://someurl.com/images/test.png',
      'https://someurl.com/audio/test.mp3',
      'https://someurl.com/audio/test.wav',
      'https://someurl.com/video/test.mp4',
      'https://someurl.com/media/test.mov'
    ];
    final mediaTypes = urls.map((url) => Media(url: url).mediaType).toList();
    expect(mediaTypes, [
      MediaType.image,
      MediaType.image,
      MediaType.image,
      MediaType.audio,
      MediaType.audio,
      MediaType.video,
      MediaType.unknown,
    ]);
  });
}