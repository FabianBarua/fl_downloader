import 'dart:async';

import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int progress = 0;
  late StreamSubscription progressStream;

  @override
  void initState() {
    FlDownloader.initialize();
    progressStream = FlDownloader.progressStream.listen((event) {
      if (event.status == DownloadStatus.successful) {
        setState(() {
          progress = event.progress;
          print("object");
        });
        FlDownloader.openFile(
          filePath: event.filePath,
        );
      } else if (event.status == DownloadStatus.running) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          progress = event.progress;
        });
      } else if (event.status == DownloadStatus.failed) {
        debugPrint('event: $event');
        debugPrint('Download failed');
      } else if (event.status == DownloadStatus.paused) {
        debugPrint('Download paused');
        Future.delayed(
          const Duration(milliseconds: 250),
          () => FlDownloader.attachDownloadProgress(event.downloadId),
        );
      } else if (event.status == DownloadStatus.pending) {
        debugPrint('Download pending');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    progressStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlDownloader example app'),
        ),
        body: Stack(
          children: [
            if (progress > 0 && progress < 100)
              Center(
                child: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(color: Color.fromARGB(255, 198, 198, 198), borderRadius: BorderRadius.circular(80),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding:EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: Text("Descargado")),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.orange,
                            backgroundColor: Color.fromARGB(255, 0, 0, 0),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.file_download),
          onPressed: () async {
            final permission = await FlDownloader.requestPermission();
            if (permission == StoragePermissionStatus.granted) {
              await FlDownloader.download(
                "https://storage.alphaplay.tv/alphaplay.apk",
                fileName: 'teste.apk',
              );
            } else {
              debugPrint('Permission denied =(');
            }
          },
        ),
      ),
    );
  }
}
