import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/department/department_status.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class DepartmentForm extends StatefulWidget {
  final DepartmentModel model;

  const DepartmentForm({super.key, required this.model});

  @override
  State<DepartmentForm> createState() => DepartmentFormState();
}

class DepartmentFormState extends State<DepartmentForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _descriptionKey = const FormKey<String>(#description);
  final _managerNameKey = const FormKey<String>(#managerName);
  final _contactEmailKey = const FormKey<String>(#contactEmail);
  final _contactPhoneKey = const FormKey<String>(#contactPhone);
  final _locationKey = const FormKey<String>(#location);
  final _notesKey = const FormKey<String>(#notes);

  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.model.departmentStatus == DepartmentStatusEnum.active;
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool validateForm() {
    _formController.revalidate(context, FormValidationMode.submitted);
    if (mounted) setState(() {});
    return _formController.errors.isEmpty;
  }

  DepartmentModel get departmentModel {
    return widget.model.copyWith(
      name: _formController.getValue(_nameKey) ?? widget.model.name,
      description: _formController.getValue(_descriptionKey) ?? widget.model.description,
      managerName: _formController.getValue(_managerNameKey) ?? widget.model.managerName,
      contactEmail: _formController.getValue(_contactEmailKey) ?? widget.model.contactEmail,
      contactPhone: _formController.getValue(_contactPhoneKey) ?? widget.model.contactPhone,
      location: _formController.getValue(_locationKey) ?? widget.model.location,
      notes: _formController.getValue(_notesKey) ?? widget.model.notes,
      departmentStatus: _isActive ? DepartmentStatusEnum.active : DepartmentStatusEnum.inactive,
      isActive: _isActive, // keep backward compatibility
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      controller: _formController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FxDivider(title: 'Dados do Departamento', icon: Symbols.domain),
          Row(
            spacing: 12,
            children: [
              const Text('Depto. Ativo:').small().muted(),
              Switch(
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),
            ],
          ).paddingOnly(bottom: 24),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FormField<String>(
                  key: _nameKey,
                  label: const Text('Nome do Departamento'),
                  validator: const NotEmptyValidator(message: 'Nome obrigatório'),
                  child: TextField(initialValue: widget.model.name, placeholder: const Text('Ex: Recursos Humanos, TI...')),
                ),
              ),
              Expanded(
                flex: 2,
                child: FormField<String>(
                  key: _managerNameKey,
                  label: const Text('Responsável / Gestor'),
                  child: TextField(initialValue: widget.model.managerName ?? '', placeholder: const Text('Nome do coordenador...')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          FormField<String>(
            key: _descriptionKey,
            label: const Text('Descrição / Atribuições'),
            validator: const NotEmptyValidator(message: 'Descrição obrigatória'),
            child: TextArea(
              initialValue: widget.model.description,
              placeholder: const Text('Descreva o escopo e foco do departamento...'),
              minLines: 2,
              maxLines: 4,
            ),
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Localização & Contato', icon: Symbols.meeting_room),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<String>(
                  key: _locationKey,
                  label: const Text('Local (Andar, Sala, Prédio)'),
                  child: TextField(initialValue: widget.model.location ?? '', placeholder: const Text('Ex: 5º Andar, Bloco C')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _contactEmailKey,
                  label: const Text('E-mail do Departamento'),
                  child: TextField(initialValue: widget.model.contactEmail ?? '', placeholder: const Text('Ex: rh@empresa.com')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _contactPhoneKey,
                  label: const Text('Telefone / Ramal'),
                  child: TextField(initialValue: widget.model.contactPhone ?? '', placeholder: const Text('Ex: (11) 9999-9999 / Ramal 42')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Observações Finais', icon: Symbols.notes),

          FormField<String>(
            key: _notesKey,
            label: const Text('Anotações'),
            child: TextArea(
              initialValue: widget.model.notes ?? '',
              placeholder: const Text('Pode conter custo orçamentário padrão, dependências ou regras gerais.'),
              minLines: 3,
              maxLines: 6,
            ),
          ).paddingOnly(bottom: 48),
        ],
      ),
    );
  }
}
