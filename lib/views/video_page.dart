import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/provider/preload_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatelessWidget {
  const VideoPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PreloadProvider>(
        builder: (context, provider, child) {
          return PageView.builder(
            itemCount: provider.urls.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) => provider.onVideoIndexChanged(context, index),
            itemBuilder: (context, index) {
              final bool isLoading = (provider.isLoading && index == provider.urls.length - 1);
              return provider.focusedIndex == index ? VideoWidget(isLoading: isLoading, controller: provider.controllers[index]!) : const SizedBox();
            },
          );
        },
      ),
    );
  }
}

/// Custom Feed Widget consisting video
class VideoWidget extends StatelessWidget {
  const VideoWidget({
    Key? key,
    required this.isLoading,
    required this.controller,
  }) : super(key: key);

  final bool isLoading;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: VideoPlayer(controller)),
        AnimatedCrossFade(
          alignment: Alignment.bottomCenter,
          sizeCurve: Curves.decelerate,
          duration: const Duration(milliseconds: 400),
          firstChild: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: 8,
            ),
          ),
          secondChild: const SizedBox(),
          crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
