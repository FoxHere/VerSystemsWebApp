//----------------------------------------------------------------------Interface
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract interface class QuestionType {
  String get dataType;
  String get typeDescription;
  Widget get typeIcon;
  String get typeTitle;
}

class TypeSimpleText extends QuestionType {
  static final TypeSimpleText _instance = TypeSimpleText._internal();

  factory TypeSimpleText() {
    return _instance;
  }

  TypeSimpleText._internal();

  @override
  String get dataType => 'simpleTextInput';

  @override
  String get typeDescription => 'Todos os caractéres';

  @override
  Widget get typeIcon => const Icon(Icons.abc, size: 20);

  @override
  String get typeTitle => 'Texto';
}

class TypeSignature extends QuestionType {
  static final TypeSignature _instance = TypeSignature._internal();

  factory TypeSignature() {
    return _instance;
  }

  TypeSignature._internal();
  @override
  String get dataType => 'signatureInput';

  @override
  String get typeDescription => 'Desenhe sua assinatura';

  @override
  Widget get typeIcon => const Icon(Symbols.signature, size: 20);

  @override
  String get typeTitle => 'Assinatura';
}

class TypeNumber extends QuestionType {
  static final TypeNumber _instance = TypeNumber._internal();

  factory TypeNumber() {
    return _instance;
  }

  TypeNumber._internal();

  @override
  String get dataType => 'numberInput';

  @override
  String get typeDescription => '0-9';

  @override
  Widget get typeIcon => const Icon(Icons.numbers_outlined, size: 20);

  @override
  String get typeTitle => 'Números';
}

class TypeCellphone extends QuestionType {
  @override
  String get dataType => 'cellphoneInput';

  @override
  String get typeDescription => '(00) 00000-0000';

  @override
  Widget get typeIcon => const Icon(Icons.phone_android_outlined, size: 20);

  @override
  String get typeTitle => 'Celular';
}

class TypeCnpj extends QuestionType {
  @override
  String get dataType => 'cnpjInput';

  @override
  String get typeDescription => '00.000.000/0000-00';

  @override
  Widget get typeIcon => const Icon(Icons.apartment_outlined, size: 20);

  @override
  String get typeTitle => 'CNPJ';
}

class TypeCpf extends QuestionType {
  @override
  String get dataType => 'cpfInput';

  @override
  String get typeDescription => '000.000.000-00';

  @override
  Widget get typeIcon => const Icon(Icons.badge_outlined, size: 20);

  @override
  String get typeTitle => 'CPF';
}

class TypeHiddenText extends QuestionType {
  @override
  String get dataType => 'hiddenTextInput';

  @override
  String get typeDescription => '************';

  @override
  Widget get typeIcon => const Icon(Icons.visibility_off_outlined, size: 20);

  @override
  String get typeTitle => 'Texto oculto';
}

class TypeListBoxMultiSelect extends QuestionType {
  @override
  String get dataType => 'listboxMultiSelect';

  @override
  String get typeDescription => 'Seleção multipla';

  @override
  Widget get typeIcon => const Icon(Icons.checklist_outlined, size: 20);

  @override
  String get typeTitle => 'Lista múltipla';
}

class TypeListBoxSingleSelect extends QuestionType {
  static final TypeListBoxSingleSelect _instance = TypeListBoxSingleSelect._internal();

  factory TypeListBoxSingleSelect() {
    return _instance;
  }

  TypeListBoxSingleSelect._internal();

  @override
  String get dataType => 'listboxSingleSelect';

  @override
  String get typeDescription => 'Seleção única';

  @override
  Widget get typeIcon => const Icon(Icons.list, size: 20);

  @override
  String get typeTitle => 'Lista única';
}

class TypeRg extends QuestionType {
  @override
  String get dataType => 'rgInput';

  @override
  String get typeDescription => '00.000.000-X';

  @override
  Icon get typeIcon => const Icon(Icons.badge_outlined, size: 20);

  @override
  String get typeTitle => 'RG';
}

class TypeTelephone extends QuestionType {
  @override
  String get dataType => 'telephoneInput';

  @override
  String get typeDescription => '(00) 0000-0000';

  @override
  Widget get typeIcon => const Icon(Icons.call, size: 20);

  @override
  String get typeTitle => 'Telefone fixo';
}

class TypeRadioButton extends QuestionType {
  static final TypeRadioButton _instance = TypeRadioButton._internal();

  factory TypeRadioButton() {
    return _instance;
  }

  TypeRadioButton._internal();

  @override
  String get dataType => 'radioButtonInput';

  @override
  String get typeDescription => '() Opção 1, () Opção 2 ....';

  @override
  Widget get typeIcon => const Icon(Icons.radio, size: 20);

  @override
  String get typeTitle => 'Botão rádio';
}

class TypeCheckbox extends QuestionType {
  static final TypeCheckbox _instance = TypeCheckbox._internal();

  factory TypeCheckbox() {
    return _instance;
  }
  TypeCheckbox._internal();

  @override
  String get dataType => 'checkboxInput';

  @override
  String get typeDescription => '[] Opção 1, [] Opção 2 ....';

  @override
  Widget get typeIcon => const Icon(Icons.check_box, size: 20);

  @override
  String get typeTitle => 'Checkbox';
}

class TypeImagePicker extends QuestionType {
  static final TypeImagePicker _instance = TypeImagePicker._internal();

  factory TypeImagePicker() {
    return _instance;
  }

  TypeImagePicker._internal();

  @override
  String get dataType => 'imagePickerInput';

  @override
  String get typeDescription => 'Upload de imagem';

  @override
  Widget get typeIcon => const Icon(Icons.photo_album, size: 20);

  @override
  String get typeTitle => 'Imagem';
}

class TypeDateInput extends QuestionType {
  static final TypeDateInput _instance = TypeDateInput._internal();

  factory TypeDateInput() {
    return _instance;
  }

  TypeDateInput._internal();

  @override
  String get dataType => 'dateInput';

  @override
  String get typeDescription => 'Data';

  @override
  Widget get typeIcon => const Icon(Icons.calendar_month, size: 20);

  @override
  String get typeTitle => 'Data';
}
