import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/components/pages/report_page.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/components/report/report_view_model.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_generator.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_preview.dart';
import 'package:versystems_app/ui/shared/components/pdf/fx_pdf_styles.dart';


class ReportView extends StatefulWidget {
  final ActivityModel task;
  final FxPdfStyles styles;
  const ReportView({super.key, required this.task, required this.styles});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final viewModel = Get.find<ReportViewModel<ActivityModel>>();

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    final initPages = <PdfPageBuilder<ActivityModel>>[
      reportPage,
    ];

    viewModel.pdfBytes = null;
    viewModel.update();
    viewModel.generateReport(
      data: widget.task,
      pages: initPages,
      styles: widget.styles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportViewModel<ActivityModel>>(
      init: viewModel,
      builder: (context) {
        if (viewModel.pdfBytes != null) {
          return FxPdfPreview(pdfBytes: (_) async => viewModel.pdfBytes!);
        }
        return CircularProgressIndicator();
      },
    );
  }
}
