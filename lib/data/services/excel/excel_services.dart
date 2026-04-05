import 'dart:js_interop';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_status_enum.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/section_model.dart';
import 'package:web/web.dart' as web;

class ExcelTemplateService {
  static Future<void> downloadTemplate() async {
    final excel = Excel.createExcel();
    final formularySheet = excel['Formulario'];
    excel.delete('Sheet1');
    // Headers
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#735EAB'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final headers = ['SESSÂO', 'PERGUNTA', 'TIPO', 'OBRIGATÓRIO', 'OPÇÕES', 'INSTRUÇÕES'];
    // var formularyHeaderCell = formularySheet.cell(CellIndex.indexByString('A1'));

    for (var i = 0; i < headers.length; i++) {
      final formularyHeaderCell = formularySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      formularyHeaderCell.value = TextCellValue(headers[i]);
      formularyHeaderCell.cellStyle = headerStyle;
    }
    // Example Rows
    formularySheet.appendRow([
      TextCellValue('Informações Gerais'),
      TextCellValue('Qual a sua pergunta 1 da Informações Gerais?'),
      TextCellValue('simpleTextInput'),
      IntCellValue(1),
      TextCellValue(''),
      TextCellValue('Instrução opcional de exemplo 1'),
    ]);
    formularySheet.appendRow([
      TextCellValue('Informações Gerais'),
      TextCellValue('Qual a sua pergunta 2 da Informações Gerais?'),
      TextCellValue('simpleTextInput'),
      IntCellValue(1),
      TextCellValue(''),
      TextCellValue('Instrução opcional de exemplo 2'),
    ]);
    formularySheet.appendRow([
      TextCellValue('Informações Gerais'),
      TextCellValue('Qual a sua pergunta 3 da Informações Gerais?'),
      TextCellValue('simpleTextInput'),
      IntCellValue(1),
      TextCellValue(''),
      TextCellValue('Instrução opcional de exemplo 3'),
    ]);
    // -----------------------------------------------------------------------
    formularySheet.appendRow([
      TextCellValue('Informações Adicionais'),
      TextCellValue('Qual a sua pergunta 1 da Informações Adicionais?'),
      TextCellValue('listboxSingleSelect'),
      IntCellValue(0),
      TextCellValue('Opção 1; Opção 2; Opção 3'),
      TextCellValue('Instrução opcional de exemplo 1'),
    ]);
    formularySheet.appendRow([
      TextCellValue('Informações Adicionais'),
      TextCellValue('Qual a sua pergunta 2 da Informações Adicionais?'),
      TextCellValue('simpleTextInput'),
      IntCellValue(0),
      TextCellValue(''),
      TextCellValue('Instrução opcional de exemplo 2'),
    ]);
    formularySheet.appendRow([
      TextCellValue('Informações Adicionais'),
      TextCellValue('Qual a sua pergunta 3 da Informações Adicionais?'),
      TextCellValue('radioButtonInput'),
      IntCellValue(0),
      TextCellValue('Opção 1; Opção 2;'),
      TextCellValue('Instrução opcional de exemplo 3'),
    ]);

    final typeListSheet = excel['Tipos de Perguntas'];
    final typeHeaders = ['TIPO DE PERGUNTA', 'DESCRIÇÃO'];

    for (var i = 0; i < typeHeaders.length; i++) {
      final typeListHeaderCell = typeListSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      typeListHeaderCell.value = TextCellValue(typeHeaders[i]);
      typeListHeaderCell.cellStyle = headerStyle;
    }
    typeListSheet.appendRow([TextCellValue('Tipo de Pergunta'), TextCellValue('Descrição')]);
    typeListSheet.appendRow([TextCellValue('simpleTextInput'), TextCellValue('Pergunta de texto simples')]);
    typeListSheet.appendRow([TextCellValue('numberInput'), TextCellValue('Pergunta de números')]);
    typeListSheet.appendRow([TextCellValue('cellphoneInput'), TextCellValue('Pergunta de telefone')]);
    typeListSheet.appendRow([TextCellValue('cnpjInput'), TextCellValue('Pergunta de CNPJ')]);
    typeListSheet.appendRow([TextCellValue('cpfInput'), TextCellValue('Pergunta de CPF')]);
    typeListSheet.appendRow([TextCellValue('rgInput'), TextCellValue('Pergunta de RG')]);
    typeListSheet.appendRow([TextCellValue('telephoneInput'), TextCellValue('Pergunta de Telefone')]);
    typeListSheet.appendRow([TextCellValue('dateInput'), TextCellValue('Pergunta de Data')]);
    typeListSheet.appendRow([TextCellValue('hiddenTextInput'), TextCellValue('Pergunta com Texto Oculto')]);
    typeListSheet.appendRow([TextCellValue('listboxMultiSelect'), TextCellValue('Pergunta com Lista Multipla')]);
    typeListSheet.appendRow([TextCellValue('listboxSingleSelect'), TextCellValue('Pergunta com Lista Simples')]);
    typeListSheet.appendRow([TextCellValue('radioButtonInput'), TextCellValue('Pergunta com Botão Rádio')]);
    typeListSheet.appendRow([TextCellValue('checkboxInput'), TextCellValue('Pergunta de Checkbox')]);
    typeListSheet.appendRow([TextCellValue('imagePickerInput'), TextCellValue('Pergunta com Imagem')]);

    // Initialize Excel download
    final bytes = excel.encode()!;
    Uint8List uIntList = Uint8List.fromList(bytes);
    final jsArray = uIntList.buffer.toJS;
    final blob = web.Blob([jsArray].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'template.xlsx';
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
  }

  static Future parseExcel(Uint8List fileBytes, String formularyId) async {
    final excel = Excel.decodeBytes(fileBytes);
    final formularySheet = excel.tables['Formulario'];
    if (formularySheet == null) {
      throw Exception('Planilha de formulário mal formatada');
    }

    final sectionsMap = <String, SectionModel>{};

    for (var i = 1; i < formularySheet.rows.length; i++) {
      final uuid = const Uuid().v4();
      final row = formularySheet.rows[i];
      if (row.isEmpty) continue;
      final sectionTitle = row[0]?.value.toString().trim() ?? '';
      final questionName = row[1]?.value.toString().trim() ?? '';
      final questionType = row[2]?.value.toString().trim() ?? '';
      final isRequired = row[3]?.value.toString().trim() ?? '0';
      final options = row[4]?.value.toString().trim();
      final instructions = row[5]?.value.toString().trim();

      final question = QuestionModel(
        id: uuid,
        question: questionName.toString(),
        questionType: questionType.toString(),
        questionRequired: isRequired == '1',
        questionOptions: options,
        questionInstructions: instructions,
      );

      if (!sectionsMap.containsKey(sectionTitle)) {
        sectionsMap[sectionTitle] = SectionModel(id: uuid, sectionTitle: sectionTitle, questions: []);
      }
      sectionsMap[sectionTitle]!.questions.add(question);
    }
    return FormularyModel(
      id: formularyId == 'new' ? '' : formularyId,
      title: 'Formulário Importado',
      description: 'Formulário importado via planilha de Excel',
      formStatus: FormStatusEnum.editing,
      sections: sectionsMap.values.toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
