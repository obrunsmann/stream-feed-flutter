import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stream_feed_flutter/src/media/gallery_header.dart';
import 'package:stream_feed_flutter/stream_feed_flutter.dart';

// ignore_for_file: cascade_invocations

/// Displays [Media] from a Feed in fullscreen.
class FullscreenMedia extends StatefulWidget {
  /// Builds a [FullscreenMedia].
  const FullscreenMedia({
    Key? key,
    required this.media,
    this.startIndex = 0,
  }) : super(key: key);

  /// The media to display.
  ///
  /// Can be audio, images, or videos.
  final List<Media> media;

  /// The first index of the media being shown.
  final int startIndex;

  @override
  _FullscreenMediaState createState() => _FullscreenMediaState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Media>('media', media));
    properties.add(IntProperty('startIndex', startIndex));
  }
}

class _FullscreenMediaState extends State<FullscreenMedia>
    with SingleTickerProviderStateMixin {
  // Whether to display the image options to the user by default or not.
  bool _optionsShown = true;

  late final AnimationController _controller;
  late final PageController _pageController;

  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController = PageController(initialPage: widget.startIndex);
    _currentPage = widget.startIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return PageView.builder(
                controller: _pageController,
                itemCount: widget.media.length,
                onPageChanged: (val) {
                  setState(() => _currentPage = val);
                },
                itemBuilder: (context, index) {
                  final media = widget.media[index];
                  if (media.mediaType == MediaType.image && media.isValidUrl) {
                    return PhotoView(
                      imageProvider: NetworkImage(media.url),
                      maxScale: PhotoViewComputedScale.covered,
                      minScale: PhotoViewComputedScale.contained,
                      onTapUp: (a, b, c) {
                        setState(() => _optionsShown = !_optionsShown);
                        if (_controller.isCompleted) {
                          _controller.reverse();
                        } else {
                          _controller.forward();
                        }
                      },
                      loadingBuilder: (context, event) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  } else {
                    // TODO: handle other media types
                    return Container();
                  }
                },
              );
            },
          ),
          AnimatedOpacity(
            opacity: _optionsShown ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GalleryHeader(
                  currentIndex: _currentPage,
                  totalMedia: widget.media.length,
                  onBackButtonPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}