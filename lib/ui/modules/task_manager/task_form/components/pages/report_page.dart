import 'package:flutter/services.dart' show rootBundle;
import 'package:fx_ui/fx_ui.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';

Future<pw.Page> reportPage(PdfPageFormat format, ActivityModel data, int index, int total, FxPdfStyles styles) async {
  pw.MemoryImage? logoImage;
  try {
    final byteData = await rootBundle.load('assets/images/common/logos/logo_01.png');
    logoImage = pw.MemoryImage(byteData.buffer.asUint8List());
  } catch (_) {
    // Caso falhe carregar a imagem, continuaremos sem o logo
  }

  final bodyWidgets = await buildBody(data, styles);

  return pw.MultiPage(
    maxPages: 999,
    theme: pw.ThemeData.withFont(), // default themes
    pageFormat: format.copyWith(
      marginLeft: styles.leftMargin,
      marginRight: styles.rightMargin,
      marginTop: styles.topMargin,
      marginBottom: styles.bottomMargin,
    ),
    header: (context) => buildHeader(styles, data, logoImage),
    footer: (context) => buildFooter(context),
    build: (context) => bodyWidgets,
  );
}

pw.Widget buildHeader(FxPdfStyles styles, ActivityModel data, pw.MemoryImage? logoImage) {
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final String createdAtStr = data.createdAt != null ? dateFormat.format(data.createdAt!) : 'N/D';
  final String updatedAtStr = data.updatedAt != null ? dateFormat.format(data.updatedAt!) : 'N/D';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Relatório de Tarefa',
                  style: pw.TextStyle(color: PdfColors.blueGrey800, fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 12),
                pw.Text(data.name, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                if (data.instructions != null && data.instructions!.isNotEmpty)
                  pw.Text(data.instructions!, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
          ),
          if (logoImage != null)
            pw.Container(
              height: 50,
              width: 150,
              alignment: pw.Alignment.centerRight,
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            ),
        ],
      ),
      pw.SizedBox(height: 16),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow('Responsável', data.responsible?.name ?? '-'),
                  pw.SizedBox(height: 4),
                  _infoRow('Cliente', data.client?.name ?? '-'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _infoRow('Criado em', createdAtStr),
                  pw.SizedBox(height: 4),
                  _infoRow('Atualizado em', updatedAtStr),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Divider(color: PdfColors.grey400, thickness: 1),
      pw.SizedBox(height: 10),
    ],
  );
}

pw.Widget _infoRow(String label, String value) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        '$label: ',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey800),
      ),
      pw.Expanded(
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
      ),
    ],
  );
}

pw.Widget buildFooter(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 10),
    child: pw.Text(
      'Página ${context.pageNumber} de ${context.pagesCount}',
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
    ),
  );
}

Future<List<pw.Widget>> buildBody(ActivityModel data, FxPdfStyles styles) async {
  final widgets = <pw.Widget>[];

  if (data.formulary == null || data.formulary!.sections.isEmpty) {
    widgets.add(pw.Center(child: pw.Text('Nenhum formulário preenchido.')));
    return widgets;
  }

  for (var section in data.formulary!.sections) {
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 4),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 1.5)),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              section.sectionTitle.toUpperCase(),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
            ),
          ],
        ),
      ),
    );

    for (var question in section.questions) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título da Pergunta
              pw.Text(
                question.question,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),

              // Instruções (se houver)
              if (question.questionInstructions?.isNotEmpty == true)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2, bottom: 4),
                  child: pw.Text(
                    question.questionInstructions!,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  ),
                )
              else
                pw.SizedBox(height: 6),

              // Divisor sutil
              pw.Divider(color: PdfColors.grey200, thickness: 1),
              pw.SizedBox(height: 6),

              // Resposta
              await _buildResponseWidget(question),
            ],
          ),
        ),
      );
    }
  }

  return widgets;
}

Future<pw.Widget> _buildResponseWidget(QuestionModel question) async {
  // Trata campo de resposta antigo (string) e nova estrutura
  final String textResponse = question.response?.toString().trim() ?? '';

  // Assinatura
  if (question.questionType == 'signatureInput') {
    try {
      pw.ImageProvider? imageProvider;

      // 1. Tenta obter do model signatureResponse
      final sig = question.signatureResponse;
      if (sig != null) {
        if (sig.downloadUrl != null && sig.downloadUrl!.isNotEmpty) {
          imageProvider = await networkImage(sig.downloadUrl!);
        } else if (sig.bytes.isNotEmpty) {
          imageProvider = pw.MemoryImage(sig.bytes);
        }
      }

      // 2. Tenta do imagesResponse caso esteja usando imagens genericas para assinatura
      if (imageProvider == null && question.imagesResponse != null && question.imagesResponse!.isNotEmpty) {
        final img = question.imagesResponse!.first;
        if (img.downloadUrl != null && img.downloadUrl!.isNotEmpty) {
          imageProvider = await networkImage(img.downloadUrl!);
        } else if (img.bytes.isNotEmpty) {
          imageProvider = pw.MemoryImage(img.bytes);
        }
      }

      // 3. Fallback pra string antiga
      if (imageProvider == null && textResponse.isNotEmpty) {
        imageProvider = await networkImage(textResponse);
      }

      if (imageProvider != null) {
        return pw.Container(
          height: 60,
          alignment: pw.Alignment.centerLeft,
          child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
        );
      } else {
        return pw.Text(
          'Sem assinatura',
          style: pw.TextStyle(fontSize: 11, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
        );
      }
    } catch (_) {
      return pw.Text('[Erro ao carregar assinatura]', style: const pw.TextStyle(color: PdfColors.red));
    }
  }

  // Imagens
  if (question.questionType == 'imagePickerInput') {
    bool hasImages = (question.imagesResponse != null && question.imagesResponse!.isNotEmpty);
    bool hasStringUrls = textResponse.isNotEmpty;

    if (!hasImages && !hasStringUrls) {
      return pw.Text(
        'Sem resposta',
        style: pw.TextStyle(fontSize: 11, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
      );
    }

    List<pw.Widget> imageWidgets = [];

    if (hasImages) {
      for (var img in question.imagesResponse!) {
        final imageName = img.name.isNotEmpty ? img.name : 'Imagem';
        try {
          pw.ImageProvider? imageProvider;
          if (img.downloadUrl != null && img.downloadUrl!.isNotEmpty) {
            imageProvider = await networkImage(img.downloadUrl!);
          } else if (img.bytes.isNotEmpty) {
            imageProvider = pw.MemoryImage(img.bytes);
          }

          if (imageProvider != null) {
            imageWidgets.add(_buildImageContainer(imageProvider, imageName));
          }
        } catch (_) {
          imageWidgets.add(_buildImageErrorContainer());
        }
      }
    } else if (hasStringUrls) {
      // Fallback para string separada por ';'
      final imagesUrls = textResponse.split(';').where((e) => e.isNotEmpty).toList();
      for (var img in imagesUrls) {
        final uriParts = img.split('?').first.split('_');
        final imageName = uriParts.isNotEmpty ? Uri.decodeFull(uriParts.last) : 'Imagem';
        try {
          final imageProvider = await networkImage(img);
          imageWidgets.add(_buildImageContainer(imageProvider, imageName));
        } catch (_) {
          imageWidgets.add(_buildImageErrorContainer());
        }
      }
    }

    return pw.Wrap(spacing: 12, runSpacing: 12, children: imageWidgets);
  }

  // Texto normal
  if (textResponse.isEmpty) {
    return pw.Text(
      'Sem resposta',
      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
    );
  }
  return pw.Text(textResponse, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey800));
}

pw.Widget _buildImageContainer(pw.ImageProvider imageProvider, String imageName) {
  return pw.Container(
    width: 120,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          height: 100,
          width: 120,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          imageName,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          maxLines: 2,
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

pw.Widget _buildImageErrorContainer() {
  return pw.Container(
    width: 120,
    height: 100,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.red300),
      color: PdfColors.red50,
    ),
    child: pw.Text('Erro de Imagem', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
  );
}
