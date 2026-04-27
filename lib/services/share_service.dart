import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Captures a widget as an image and shares it.
  /// Ensure the widget is wrapped in a [RepaintBoundary] with the provided [key].
  Future<void> shareWidgetAsImage({
    required GlobalKey key,
    required String text,
    required String subject,
  }) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/share_score.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  /// Simple text-only sharing as a fallback or for simple scores.
  Future<void> shareScore({required String gameTitle, required int score}) async {
    final text = 'I just scored $score on $gameTitle in Numbers! Can you beat me? 🧩📈';
    await Share.share(text, subject: 'My Numbers High Score');
  }
}
