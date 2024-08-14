import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/constants.dart';
import 'package:flutter_preload_videos/views/video_page.dart';
import 'package:provider/provider.dart';

import 'provider/preload_provider.dart';
import 'service/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// Isolate to fetch videos in the background so that the video experience is not disturbed.
/// Without isolate, the video will be paused whenever there is an API call
/// because the main thread will be busy fetching new video URLs.
///
/// https://blog.codemagic.io/understanding-flutter-isolates/
Future createIsolate(BuildContext context, int index) async {
  // Get the PreloadProvider
  final preloadProvider = Provider.of<PreloadProvider>(context, listen: false);

  // Set loading to true
  preloadProvider.isLoading = true;
  preloadProvider.notifyListeners();

  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final urls = isolateResponse as List<String>;

  // Update new URLs in provider
  preloadProvider.updateUrls(urls);
}

void getVideosTask(SendPort mySendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  mySendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final int index = message[0];
      final SendPort isolateResponseSendPort = message[1];

      final List<String> urls = await ApiService.getVideos(id: index + kPreloadLimit);

      isolateResponseSendPort.send(urls);
    }
  }
}

final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PreloadProvider()..initialize(),
      child: MaterialApp(
        key: navigationKey,
        debugShowCheckedModeBanner: false,
        home: VideoPage(),
      ),
    );
  }
}
