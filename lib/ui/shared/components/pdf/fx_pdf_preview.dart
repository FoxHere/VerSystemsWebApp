import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class FxPdfPreview extends StatelessWidget {
  final Future<Uint8List> Function(PdfPageFormat) pdfBytes;

  const FxPdfPreview({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return PdfPreview(
            maxPageWidth: constraints.maxWidth * .7,
            initialPageFormat: PdfPageFormat.a4,
            canChangePageFormat: false,
            canChangeOrientation: false,
            allowPrinting: true,
            allowSharing: true,
            canDebug: false,
            build: (format) {
              return pdfBytes(format);
            },
          );
        },
      ),
    );
  }
}
