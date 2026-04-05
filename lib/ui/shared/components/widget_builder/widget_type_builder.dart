import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_type_model.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_picker_widget.dart';
import 'package:versystems_app/ui/shared/components/signature/fx_signature_form_field.dart';

class FormFieldRequiredValidator<T> extends Validator<T> {
  final String message;
  const FormFieldRequiredValidator(this.message);

  @override
  ValidationResult? validate(BuildContext context, T? value, FormValidationMode mode) {
    if (value == null) return InvalidResult(message, state: mode);
    if (value is String && value.isEmpty) return InvalidResult(message, state: mode);
    if (value is List && value.isEmpty) return InvalidResult(message, state: mode);
    return null;
  }
}

class ShadcnStatefulCheckboxList extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onChanged;
  final String Function(String)? labelBuilder;

  const ShadcnStatefulCheckboxList({super.key, required this.items, required this.initialSelected, required this.onChanged, this.labelBuilder});

  @override
  State<ShadcnStatefulCheckboxList> createState() => _ShadcnStatefulCheckboxListState();
}

class _ShadcnStatefulCheckboxListState extends State<ShadcnStatefulCheckboxList> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialSelected);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValue();
    });
  }

  void _reportValue() {
    Data.maybeOf<FormFieldHandle>(context)?.reportNewFormValue<List<String>>(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Checkbox(
                state: selected.contains(item) ? CheckboxState.checked : CheckboxState.unchecked,
                onChanged: (val) {
                  setState(() {
                    if (val == CheckboxState.checked) {
                      selected.add(item);
                    } else if (val == CheckboxState.unchecked) {
                      selected.remove(item);
                    }
                    _reportValue();
                    widget.onChanged(selected);
                  });
                },
              ),
              Text(widget.labelBuilder != null ? widget.labelBuilder!(item) : item),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ShadcnStatefulSelect extends StatefulWidget {
  final String? initialValue;
  final List<String?> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;

  const ShadcnStatefulSelect({super.key, this.initialValue, required this.items, required this.onChanged, this.labelBuilder});

  @override
  State<ShadcnStatefulSelect> createState() => _ShadcnStatefulSelectState();
}

class _ShadcnStatefulSelectState extends State<ShadcnStatefulSelect> {
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = (widget.initialValue != null && widget.initialValue!.isNotEmpty) ? widget.initialValue : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValue();
    });
  }

  void _reportValue() {
    Data.maybeOf<FormFieldHandle>(context)?.reportNewFormValue<String>(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Select<String>(
      value: selected,
      placeholder: const Text('Selecione uma opção...'),
      onChanged: (val) {
        setState(() {
          selected = val;
          _reportValue();
          widget.onChanged(selected);
        });
      },
      itemBuilder: (context, val) {
        return Text(widget.labelBuilder != null ? widget.labelBuilder!(val) : val);
      },
      popup: (context) => SelectPopup(
        items: SelectItemList(
          children: widget.items.where((e) => e != null).map((e) {
            return SelectItemButton(value: e!, child: Text(widget.labelBuilder != null ? widget.labelBuilder!(e) : e));
          }).toList(),
        ),
      ),
    );
  }
}

class ShadcnStatefulMultiSelect extends StatefulWidget {
  final List<String> initialValue;
  final List<String?> items;
  final ValueChanged<List<String>> onChanged;
  final String Function(String)? labelBuilder;

  const ShadcnStatefulMultiSelect({super.key, required this.initialValue, required this.items, required this.onChanged, this.labelBuilder});

  @override
  State<ShadcnStatefulMultiSelect> createState() => _ShadcnStatefulMultiSelectState();
}

class _ShadcnStatefulMultiSelectState extends State<ShadcnStatefulMultiSelect> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialValue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValue();
    });
  }

  void _reportValue() {
    Data.maybeOf<FormFieldHandle>(context)?.reportNewFormValue<List<String>>(selected);
  }

  @override
  Widget build(BuildContext context) {
    return MultiSelect<String>(
      value: selected,
      placeholder: const Text('Selecione opções...'),
      onChanged: (val) {
        setState(() {
          selected = val?.toList() ?? [];
          _reportValue();
          widget.onChanged(selected);
        });
      },
      itemBuilder: (context, val) {
        return Text(widget.labelBuilder != null ? widget.labelBuilder!(val) : val);
      },
      popup: (context) => SelectPopup(
        items: SelectItemList(
          children: widget.items.where((e) => e != null).map((e) {
            return SelectItemButton(value: e!, child: Text(widget.labelBuilder != null ? widget.labelBuilder!(e) : e));
          }).toList(),
        ),
      ),
    );
  }
}

class ShadcnStatefulRadioGroup extends StatefulWidget {
  final String? initialValue;
  final List<String?> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;

  const ShadcnStatefulRadioGroup({super.key, this.initialValue, required this.items, required this.onChanged, this.labelBuilder});

  @override
  State<ShadcnStatefulRadioGroup> createState() => _ShadcnStatefulRadioGroupState();
}

class _ShadcnStatefulRadioGroupState extends State<ShadcnStatefulRadioGroup> {
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValue();
    });
  }

  void _reportValue() {
    Data.maybeOf<FormFieldHandle>(context)?.reportNewFormValue<String>(selected);
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      value: selected,
      onChanged: (val) {
        setState(() {
          selected = val;
          _reportValue();
          widget.onChanged(selected);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: widget.items.where((e) => e != null).map((e) {
          return RadioItem<String>(value: e!, trailing: Text(widget.labelBuilder != null ? widget.labelBuilder!(e) : e));
        }).toList(),
      ),
    );
  }
}

class ShadcnStatefulDatePicker extends StatefulWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;

  const ShadcnStatefulDatePicker({super.key, this.initialValue, required this.onChanged});

  @override
  State<ShadcnStatefulDatePicker> createState() => _ShadcnStatefulDatePickerState();
}

class _ShadcnStatefulDatePickerState extends State<ShadcnStatefulDatePicker> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reportValue();
    });
  }

  void _reportValue() {
    Data.maybeOf<FormFieldHandle>(context)?.reportNewFormValue<DateTime>(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return DatePicker(
      value: selectedDate,
      placeholder: const Text('DD/MM/AAAA'),
      onChanged: (date) {
        setState(() {
          selectedDate = date;
          _reportValue();
          widget.onChanged(selectedDate);
        });
      },
    );
  }
}

class WidgetTypeBuilder extends StatelessWidget {
  final QuestionType questionType;
  final String fieldKey;
  final void Function(String)? onChanged;
  final void Function(String?)? onSelectChanged;
  final void Function(List<String>)? onSelectionChanged;
  final String? initialValue;
  final List<ImageItemModel>? initialImages;
  final ImageItemModel? initialSignature;
  final String? selectedItem;
  final List<String?>? items;
  final GlobalKey<FormState>? dropdownKey;
  final String Function(String)? labelBuilder;
  final dynamic Function(List<ImageItemModel>)? onImagePicker;
  final dynamic Function(ImageItemModel)? onImageRemoved;
  final dynamic Function(ImageItemModel)? onSignatureSelected;
  final ImageServices imageServices;
  final RxBool isImageConverting;
  final bool hasValidator;
  final bool isReadMode;

  const WidgetTypeBuilder({
    super.key,
    required this.fieldKey,
    required this.imageServices,
    required this.questionType,
    required this.isImageConverting,
    this.onChanged,
    this.initialValue,
    this.initialImages,
    this.initialSignature,
    this.items,
    this.dropdownKey,
    this.onSelectChanged,
    this.onSelectionChanged,
    this.onImagePicker,
    this.onImageRemoved,
    this.onSignatureSelected,
    this.selectedItem,
    this.labelBuilder,
    this.hasValidator = false,
    this.isReadMode = false,
  });

  Validator<T>? _getValidator<T>(String message) {
    return hasValidator ? FormFieldRequiredValidator<T>(message) : null;
  }

  Widget _buildReadMode(String fallbackLabel) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(initialValue ?? fallbackLabel).large());
  }

  Widget _buildWrapper({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: child);
  }

  @override
  Widget build(BuildContext context) {
    switch (questionType) {
      //--------------------------------------------------------------------------------------------------
      case TypeImagePicker():
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Expanded(
                child: FormField<List<ImageItemModel>>(
                  key: FormKey<List<ImageItemModel>>(fieldKey),
                  validator: _getValidator<List<ImageItemModel>>('É necessário pelo menos uma imagem'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ImagePickerWidget(
                    initialImages: initialImages,
                    imageServices: imageServices,
                    isImageConverting: isImageConverting,
                    onImageSelected: onImagePicker ?? (listImages) {},
                    onImageRemoved: onImageRemoved ?? (image) {},
                    isReadMode: isReadMode,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeSignature():
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Expanded(
                child: FormField<ImageItemModel>(
                  key: FormKey<ImageItemModel>(fieldKey),
                  validator: _getValidator<ImageItemModel>('É necessário fornecer uma assinatura'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: FxSignatureFormField(
                    initialImage: initialSignature,
                    imageServices: imageServices,
                    isImageConverting: isImageConverting,
                    onSignatureSelected: onSignatureSelected ?? (image) {},
                    isReadMode: isReadMode,
                    isRequired: hasValidator,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeSimpleText():
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(initialValue: initialValue ?? '', placeholder: const Text('Insira o texto aqui...'), onChanged: onChanged),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeNumber():
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    placeholder: const Text('Insira o número aqui...'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeTelephone():
        var maskFormatterTelephone = MaskTextInputFormatter(
          mask: '(##) ####-####',
          filter: {'#': RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} ${questionType.typeDescription}'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, maskFormatterTelephone],
                    placeholder: const Text('(00) 0000-0000'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeCellphone():
        var maskFormatterCellphone = MaskTextInputFormatter(
          mask: '(##) #.####-####',
          filter: {'#': RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} ${questionType.typeDescription}'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, maskFormatterCellphone],
                    placeholder: const Text('(00) 0.0000-0000'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeCpf():
        var maskFormatterCpf = MaskTextInputFormatter(mask: '###.###.###-##', filter: {'#': RegExp(r'[0-9]')}, type: MaskAutoCompletionType.lazy);
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, maskFormatterCpf],
                    placeholder: const Text('000.000.000-00'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeRg():
        var maskFormatterRg = MaskTextInputFormatter(
          mask: '##.###.###-*',
          filter: {'#': RegExp(r'[0-9]'), '*': RegExp(r'[a-zA-Z0-9]')},
          type: MaskAutoCompletionType.lazy,
        );
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, maskFormatterRg],
                    placeholder: const Text('00.000.000-0'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeCnpj():
        var maskFormatterCnpj = MaskTextInputFormatter(
          mask: '##.###.###/####-##',
          filter: {'#': RegExp(r'[0-9]')},
          type: MaskAutoCompletionType.lazy,
        );
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, maskFormatterCnpj],
                    placeholder: const Text('00.000.000/0000-00'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeHiddenText():
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: TextField(
                    initialValue: initialValue ?? '',
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    placeholder: const Text('...'),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeListBoxSingleSelect():
        if (isReadMode) return _buildReadMode('Sem resposta');
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Este campo não pode ser vazio'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ShadcnStatefulSelect(
                    initialValue: initialValue,
                    items: items ?? [],
                    onChanged: (val) {
                      onSelectChanged?.call(val);
                    },
                    labelBuilder: labelBuilder,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeListBoxMultiSelect():
        if (isReadMode) {
          final displayVal = (initialValue?.split(';') ?? []).reversed.where((v) => v != '').join('\n');
          return _buildReadMode(displayVal == '' ? 'Sem resposta' : displayVal);
        }
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<List<String>>(
                  key: FormKey<List<String>>(fieldKey),
                  validator: _getValidator<List<String>>('Selecione pelo menos uma opção.'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ShadcnStatefulMultiSelect(
                    initialValue: (initialValue?.split(';') ?? []).where((e) => e.isNotEmpty).toList(),
                    items: items ?? [],
                    onChanged: (list) {
                      onSelectionChanged?.call(list);
                      onSelectChanged?.call(list.join(';'));
                    },
                    labelBuilder: labelBuilder,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeRadioButton():
        if (isReadMode) return _buildReadMode('Sem resposta');

        final fallbackValue = (selectedItem != null) ? selectedItem : initialValue;
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: FormKey<String>(fieldKey),
                  validator: _getValidator<String>('Selecione pelo menos uma opção.'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ShadcnStatefulRadioGroup(
                    initialValue: fallbackValue,
                    items: items ?? [],
                    onChanged: (val) {
                      onSelectChanged?.call(val);
                    },
                    labelBuilder: labelBuilder,
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeCheckbox():
        if (isReadMode) {
          final displayVal = (initialValue?.split(';') ?? []).where((v) => v != '').join('\n');
          return _buildReadMode(displayVal == '' ? 'Sem resposta' : displayVal);
        }
        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<List<String>>(
                  key: FormKey<List<String>>(fieldKey),
                  validator: _getValidator<List<String>>('Selecione pelo menos uma opção.'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ShadcnStatefulCheckboxList(
                    items: items?.whereType<String>().toList() ?? [],
                    initialSelected: (initialValue?.split(';') ?? []).where((e) => e.isNotEmpty).toList(),
                    labelBuilder: labelBuilder,
                    onChanged: (selectedList) {
                      onSelectChanged?.call(selectedList.join(';'));
                      onSelectionChanged?.call(selectedList);
                    },
                  ),
                ),
              ),
            ],
          ),
        );

      //--------------------------------------------------------------------------------------------------
      case TypeDateInput():
        if (isReadMode) return _buildReadMode('Sem resposta');

        DateTime? initDate;
        if (initialValue != null && initialValue!.length >= 10 && initialValue!.contains('/')) {
          try {
            initDate = DateFormat('dd/MM/yyyy').parse(initialValue!);
          } catch (_) {}
        }

        return _buildWrapper(
          child: Row(
            children: [
              Expanded(
                child: FormField<DateTime>(
                  key: FormKey<DateTime>(fieldKey),
                  validator: _getValidator<DateTime>('A Data é obrigatória'),
                  label: Text('${questionType.typeTitle} (${questionType.typeDescription})'),
                  child: ShadcnStatefulDatePicker(
                    initialValue: initDate,
                    onChanged: (date) {
                      if (date != null) {
                        String formatedDate = DateFormat('dd/MM/yyyy').format(date);
                        onChanged?.call(formatedDate);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Widget não definido para o tipo ${questionType.typeTitle}',
                      style: TextStyle(color: Theme.of(context).colorScheme.destructive),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
