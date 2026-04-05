import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FxPdfStyles {
  late final pw.TextStyle titleStyle;
  late final pw.TextStyle sectionTitle;
  late final pw.TextStyle questionText;
  late final pw.TextStyle normalText;
  late final pw.TextStyle instructionsText;

  // Margins configuration
  late final double leftMargin;
  late final double rightMargin;
  late final double topMargin;
  late final double bottomMargin;

  static Future<FxPdfStyles> init() async {
    final config = FxPdfStyles();

    /// Font Styles

    config.titleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    config.sectionTitle = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    config.questionText = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
    config.normalText = pw.TextStyle(fontSize: 10);
    config.instructionsText = pw.TextStyle(
      fontSize: 9,
      fontStyle: pw.FontStyle.italic,
      color: PdfColors.grey700,
    );

    /// Default margins
    config.leftMargin = 90 * 0.352777 * PdfPageFormat.mm; // 31.75 mm
    config.rightMargin = 68.85 * 0.352777 * PdfPageFormat.mm; // 24.27 mm
    config.topMargin = 77.95 * 0.352777 * PdfPageFormat.mm; // 27.47 mm
    config.bottomMargin = 57.60 * 0.352777 * PdfPageFormat.mm; // 20.32 mm

    return config;
  }
}
