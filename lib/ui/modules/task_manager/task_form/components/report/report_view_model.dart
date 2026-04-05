import 'dart:typed_data';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_generator.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';

class ReportViewModel<T> extends GetxController {
  Uint8List? pdfBytes;

  Future<void> generateReport({
    required T data, // Dados do PDF
    required List<PdfPageBuilder<T>> pages, // Lista de páginas do PDF
    required FxPdfStyles styles, // Estilos do PDF
  }) async {
    final generator = FxPdfGenerator<T>(format: PdfPageFormat.a4, styles: styles, pages: pages, data: data);
    pdfBytes = await generator.generatePdfDocument();
    update();
  }
}
