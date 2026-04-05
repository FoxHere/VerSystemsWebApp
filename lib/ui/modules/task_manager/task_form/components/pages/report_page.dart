import 'package:fx_ui/fx_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';


Future<pw.Page> reportPage(
  PdfPageFormat format,
  ActivityModel data,
  int index,
  int total,
  FxPdfStyles styles,
) async {
  final bodyWidgets = await buildBody(data, styles);

  return pw.MultiPage(
    maxPages: 999,
    theme: pw.ThemeData.withFont(
      // base: styles.baseFont,
      // bold: styles.boldFont,
      // icons: styles.iconFont,
    ),
    pageFormat: format.copyWith(
      marginLeft: styles.leftMargin,
      marginRight: styles.rightMargin,
      marginTop: styles.topMargin,
      marginBottom: styles.bottomMargin,
    ),
    // header: (context) => buildHeader(styles, data.fixVersion),
    // footer: (context) => buildFooter(context),
    build: (context) => bodyWidgets,
  );
}

Future<List<pw.Widget>> buildBody(ActivityModel data, FxPdfStyles styles) async {
  final widgets = <pw.Widget>[];
  widgets.add(
    pw.Center(
      child: pw.Padding(
        padding: pw.EdgeInsets.only(bottom: FxTheme.spacing),
        child: pw.Text(data.name, textAlign: pw.TextAlign.center, style: styles.titleStyle),
      ),
    ),
  );
  widgets.add(
    pw.Center(
      child: pw.Padding(
        padding: pw.EdgeInsets.only(bottom: FxTheme.spacing),
        child: pw.Text(
          data.instructions ?? '',
          textAlign: pw.TextAlign.justify,
          style: styles.instructionsText,
        ),
      ),
    ),
  );

  for (var section in data.formulary!.sections) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 12, bottom: 6),
        child: pw.Text(
          section.sectionTitle,
          style: styles.sectionTitle,
        ),
      ),
    );
    for (var question in section.questions) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
            question.question,
            style: styles.questionText,
          ),
        ),
      );

      // Se houver instruções adicionais
      if (question.questionInstructions?.isNotEmpty == true) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
            child: pw.Text(
              question.questionInstructions!,
              style: styles.instructionsText,
            ),
          ),
        );
      }

      // Exibe a resposta (pode ser texto, lista ou imagem)
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 8),
          child: await _buildResponseWidget(question),
        ),
      );
    }

    // Linha separadora entre seções
    widgets.add(pw.Divider(thickness: 0.3));
  }

  return widgets;
}

Future<pw.Widget> _buildResponseWidget(QuestionModel question) async {
  final String response = question.response as String;
  // Caso seja uma imagem de assinatura, exibe a imagem
  if (question.questionType == 'signatureInput' && response.trim().isNotEmpty) {
    return pw.Image(await networkImage(response));
  }
  // Caso sejam imagens (por exemplo, lista de ImageItemModel)
  if (question.questionType == 'imagePickerInput' && response.trim().isNotEmpty) {
    // Ajuste conforme o seu formato de imagem (base64, network, etc.)
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: await Future.wait(
        response.split(';').map<Future<pw.Widget>>((img) async {
          final imageName = Uri.decodeFull(img.split('?').first.split('_').last);
          final imageUrl = img;

          return pw.Container(
            width: 100,
            height: 100,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
            ),
            child: imageUrl.isEmpty
                ? pw.Text(img, style: const pw.TextStyle(fontSize: 8))
                : pw.Stack(
                    children: [
                      pw.Image(await networkImage(imageUrl)),
                      pw.Text(imageName, style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
          );
        }).toList(),
      ),
    );
  }
  if (response.trim().isNotEmpty) {
    return pw.Text(response);
  }
  // Se for algum outro tipo desconhecido
  return pw.Text(response.toString());
}
