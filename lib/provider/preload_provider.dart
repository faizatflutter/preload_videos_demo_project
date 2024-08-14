import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/main.dart';
import 'package:flutter_preload_videos/service/api_service.dart';
import 'package:video_player/video_player.dart';

class PreloadProvider extends ChangeNotifier {
  List<String> urls = [];
  Map<int, VideoPlayerController?> controllers = {};
  bool isLoading = false;
  int focusedIndex = 0;
  int reloadCounter = 0;

  /// Initialize provider by fetching the first set of videos
  Future<void> initialize() async {
    final List<String> _urls = await ApiService.getVideos();
    urls.addAll(_urls);

    await _initializeControllerAtIndex(0);
    _playControllerAtIndex(0);
    await _initializeControllerAtIndex(1);

    reloadCounter++;
    notifyListeners();
  }

  /// Update URL list with new videos
  void updateUrls(List<String> newUrls) {
    urls.addAll(newUrls);
    isLoading = false;
    reloadCounter++;
    notifyListeners();
    log('🚀🚀🚀 NEW VIDEOS ADDED');
  }

  /// Handle video index change
  void onVideoIndexChanged(BuildContext context, int index) {
    if ((index + 5) % 3 == 0 && urls.length == index + 5) {
      // Condition to fetch new videos
      // createIsolate will be called in your main file
      createIsolate(context, index);
    }

    if (index > focusedIndex) {
      _playNext(index);
    } else {
      _playPrevious(index);
    }

    focusedIndex = index;
    notifyListeners();
  }

  void _playNext(int index) {
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    _stopControllerAtIndex(index + 1);
    _disposeControllerAtIndex(index + 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index - 1);
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller = VideoPlayerController.network(urls[index]);
      controllers[index] = _controller;
      await _controller.initialize();
      log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller = controllers[index]!;
      _controller.play();
      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller = controllers[index]!;
      _controller.pause();
      _controller.seekTo(const Duration());
      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController? _controller = controllers[index];
      _controller?.dispose();
      if (_controller != null) {
        controllers.remove(_controller);
      }
      log('🚀🚀🚀 DISPOSED $index');
    }
  }
}
