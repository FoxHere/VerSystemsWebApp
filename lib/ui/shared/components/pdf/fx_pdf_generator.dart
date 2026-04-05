import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';

// Interface para criar as páginas do PDF
typedef PdfPageBuilder<T> =
    Future<pw.Page> Function(
      PdfPageFormat format, // Formato da página
      T data, // Dados da página
      int index, // Índice da página
      int total, // Total de páginas
      FxPdfStyles styles, // Estilos do PDF
    );

// Classe para gerar o PDF
class FxPdfGenerator<T> {
  final List<PdfPageBuilder<T>> pages; // Lista de páginas do PDF
  final PdfPageFormat format; // Formato da página
  final T data; // Dados do PDF
  final FxPdfStyles styles; // Estilos do PDF

  FxPdfGenerator({
    required this.pages,
    required this.format,
    required this.data,
    required this.styles,
  });

  // Método para gerar o PDF
  Future<Uint8List> generatePdfDocument() async {
    final document = pw.Document(pageMode: PdfPageMode.outlines);
    final totalSteps = pages.length;

    for (var i = 0; i < totalSteps; i++) {
      final page = await pages[i](format, data, i, totalSteps, styles);
      document.addPage(page);
    }
    // Salvar o PDF significa transformar o documento em um array de bytes
    return await document.save();
  }
}
