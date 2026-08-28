import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';

/// Widget dedicado para exibir badges de status de uma pergunta no Form Builder.
///
/// Exibe badges reativos para:
/// 1. Campo Obrigatório (Vermelho -> "Obrigatória")
/// 2. Instrução preenchida (Azul -> "Instrução X caracteres")
/// 3. Opções cadastradas (Laranja -> "X Opções" para tipos que possuem lista de opções)
class QuestionBadgesWidget extends StatelessWidget {
  final QuestionModel question;

  const QuestionBadgesWidget({
    super.key,
    required this.question,
  });

  /// Mapeamento dos tipos de pergunta para títulos amigáveis em português.
  static const Map<String, String> _typeTitles = {
    'simpleTextInput': 'Texto',
    'numberInput': 'Números',
    'telephoneInput': 'Telefone fixo',
    'cellphoneInput': 'Celular',
    'cnpjInput': 'CNPJ',
    'cpfInput': 'CPF',
    'rgInput': 'RG',
    'hiddenTextInput': 'Texto oculto',
    'listboxSingleSelect': 'Lista única',
    'listboxMultiSelect': 'Lista múltipla',
    'radioButtonInput': 'Botão rádio',
    'checkboxInput': 'Checkbox',
    'imagePickerInput': 'Imagem',
    'dateInput': 'Data',
    'signatureInput': 'Assinatura',
    'gpsLocationInput': 'Localização GPS',
  };

  /// Retorna o título formatado em português do tipo da pergunta.
  String get _questionTypeLabel => _typeTitles[question.questionType] ?? question.questionType;

  /// Verifica se a pergunta é do tipo que utiliza lista de opções.
  bool get _supportsOptions {
    final type = question.questionType;
    return type == 'listboxMultiSelect' ||
        type == 'listboxSingleSelect' ||
        type == 'radioButtonInput' ||
        type == 'checkboxInput';
  }

  /// Retorna a quantidade de opções válidas cadastradas.
  int get _optionsCount {
    final optionsStr = question.questionOptions ?? '';
    if (optionsStr.trim().isEmpty) return 0;
    return optionsStr
        .split(RegExp(r';\n|[\n;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .length;
  }

  /// Retorna o texto da instrução sanitizado.
  String? get _instructionText => question.questionInstructions?.trim();

  /// Verifica se possui instrução válida preenchida.
  bool get _hasInstruction => _instructionText != null && _instructionText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Badge 1: Tipo da pergunta (Cinza neutro - Sempre visível)
    badges.add(_buildBadge(
      context: context,
      label: _questionTypeLabel,
      baseColor: const Color(0xFF64748B), // Cinza Slate 500
    ));

    // Badge 2: Obrigatória (Vermelho)
    if (question.questionRequired) {
      badges.add(_buildBadge(
        context: context,
        label: 'Obrigatória',
        baseColor: const Color(0xFFEF4444), // Vermelho suave (Red 500)
      ));
    }

    // Badge 3: Instrução X caracteres (Azul)
    if (_hasInstruction) {
      final charCount = _instructionText!.length;
      badges.add(_buildBadge(
        context: context,
        label: 'Instrução $charCount caracteres',
        baseColor: const Color(0xFF3B82F6), // Azul suave (Blue 500)
      ));
    }

    // Badge 4: X Opções (Laranja)
    if (_supportsOptions) {
      final count = _optionsCount;
      badges.add(_buildBadge(
        context: context,
        label: '$count Opções',
        baseColor: const Color(0xFFF97316), // Laranja suave (Orange 500)
      ));
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: badges,
      ),
    );
  }

  Widget _buildBadge({
    required BuildContext context,
    required String label,
    required Color baseColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = baseColor.withValues(alpha: isDark ? 0.18 : 0.10);
    final borderColor = baseColor.withValues(alpha: isDark ? 0.35 : 0.25);
    final textColor = isDark ? _lighten(baseColor, 0.2) : _darken(baseColor, 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
