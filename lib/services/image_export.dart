import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Renderiza um widget (via RepaintBoundary) em PNG e permite COMPARTILHAR ou
/// SALVAR na galeria. Usado pelo editor de imagem.
class ImageExport {
  ImageExport._();

  static Future<Uint8List?> capture(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  static Future<void> share(Uint8List bytes, {String text = ''}) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );
  }

  /// Salva na galeria. Lança em caso de falha (o chamador trata o feedback).
  static Future<void> saveToGallery(Uint8List bytes) async {
    if (!await Gal.hasAccess()) {
      await Gal.requestAccess();
    }
    await Gal.putImageBytes(bytes, album: 'Daily Quotes');
  }
}
