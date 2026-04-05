import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class ActivityForm extends StatefulWidget {
  final ActivityModel model;
  final List<UserModel> availableUsersList;
  final List<FormularyModel> availableFormularyList;
  final List<ClientModel> availableClientsList;

  const ActivityForm({
    super.key,
    required this.model,
    required this.availableUsersList,
    required this.availableFormularyList,
    required this.availableClientsList,
  });

  @override
  State<ActivityForm> createState() => ActivityFormState();
}

class ActivityFormState extends State<ActivityForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _instructionsKey = const FormKey<String>(#instructions);
  final _startDateKey = const FormKey<DateTime>(#startDate);
  final _endDateKey = const FormKey<DateTime>(#endDate);
  final _responsableKey = const FormKey<UserModel>(#responsable);
  final _formularyKey = const FormKey<FormularyModel>(#formulary);
  final _clientKey = const FormKey<ClientModel>(#client);

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool validateForm() {
    _formController.revalidate(context, FormValidationMode.submitted);
    // Force UI update to show errors
    setState(() {});
    return _formController.errors.isEmpty;
  }

  ActivityModel get activityModel {
    return widget.model.copyWith(
      id: widget.model.id,
      name: _formController.getValue(_nameKey) ?? widget.model.name,
      instructions: _formController.getValue(_instructionsKey) ?? widget.model.instructions,
      startDateTime: _formController.getValue(_startDateKey) ?? widget.model.startDateTime,
      endDateTime: _formController.getValue(_endDateKey) ?? widget.model.endDateTime,
      responsable: _formController.getValue(_responsableKey) ?? widget.model.responsable,
      formulary: _formController.getValue(_formularyKey) ?? widget.model.formulary,
      client: _formController.getValue(_clientKey) ?? widget.model.client,
      createdAt: widget.model.createdAt,
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
          FxDivider(title: 'Instruções Principais', icon: Symbols.list_alt),

          Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: _nameKey,
                  label: const Text('Nome da Atividade'),
                  validator: const NotEmptyValidator(message: 'Nome da Atividade é obrigatório'),
                  child: TextField(initialValue: widget.model.name, placeholder: const Text('Digite o nome da atividade...')),
                ).paddingOnly(bottom: 24),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: _instructionsKey,
                  label: const Text('Instruções/Descrição'),
                  child: TextArea(
                    initialValue: widget.model.instructions ?? '',
                    placeholder: const Text('Digite as instruções...'),
                    minLines: 3,
                    maxLines: 8,
                  ),
                ).paddingOnly(bottom: 24),
              ),
            ],
          ),

          FxDivider(title: 'Período da Atividade', icon: Symbols.calendar_month),

          Row(
            spacing: 24,
            children: [
              Expanded(
                child: FormField<DateTime>(
                  key: _startDateKey,
                  label: const Text('Data de Início'),
                  validator: const NonNullValidator(message: 'Data de Início é obrigatória'),
                  child: DatePicker(
                    value: widget.model.startDateTime,
                    mode: PromptMode.popover,
                    placeholder: const Text('Selecionar data'),
                    onChanged: (date) {
                      if (date != null) {
                        setState(() {
                          widget.model.startDateTime = date;
                        });
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: FormField<DateTime>(
                  key: _endDateKey,
                  label: const Text('Data de Término'),
                  validator:
                      ConditionalValidator<DateTime>(
                        (value) {
                          if (value == null) return false;
                          final startDate = _formController.getValue(_startDateKey);
                          if (startDate != null && value.isBefore(startDate)) {
                            return false;
                          }
                          return true;
                        },
                        message: 'A data final deve ser posterior ou igual à inicial',
                        dependencies: [_startDateKey],
                      ) &
                      const NonNullValidator(message: 'Data de Término é obrigatória'),
                  child: DatePicker(
                    value: widget.model.endDateTime,
                    mode: PromptMode.popover,
                    placeholder: const Text('Selecionar data'),
                    onChanged: (date) {
                      if (date != null) {
                        setState(() {
                          widget.model.endDateTime = date;
                          _formController.revalidate(context, FormValidationMode.changed);
                        });
                      }
                      // Fecha automaticamente o datepicker retirando o foco
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          FxDivider(title: 'Responsável & Formulário', icon: Symbols.person_pin),

          Row(
            spacing: 24,
            children: [
              Expanded(
                child: FormField<UserModel>(
                  key: _responsableKey,
                  label: const Text('Responsável'),
                  validator: const NonNullValidator(message: 'Responsável é obrigatório'),
                  child: Select<UserModel>(
                    value: widget.model.responsable,
                    placeholder: const Text('Selecione um usuário'),
                    onChanged: (user) {
                      setState(() {
                        widget.model.responsable = user;
                      });
                    },
                    itemBuilder: (context, user) => Text(user.name),
                    popup: (context) => SelectPopup.builder(
                      searchPlaceholder: const Text('Pesquisar responsável...'),
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhum responsável encontrado'),
                      ),
                      builder: (context, searchQuery) {
                        final query = searchQuery?.toLowerCase() ?? '';
                        final filtered = widget.availableUsersList
                            .where((user) => user.name.toLowerCase().contains(query))
                            .toList();
                        return SelectItemList(
                          children: filtered
                              .map((user) => SelectItemButton(value: user, child: Text(user.name)))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FormField<FormularyModel>(
                  key: _formularyKey,
                  label: const Text('Formulário'),
                  validator: const NonNullValidator(message: 'Formulário é obrigatório'),
                  child: Select<FormularyModel>(
                    value: widget.model.formulary,
                    placeholder: const Text('Selecione um formulário'),
                    itemBuilder: (context, form) => Text(form.title),
                    onChanged: (form) {
                      setState(() {
                        widget.model.formulary = form;
                      });
                    },
                    popup: (context) => SelectPopup.builder(
                      searchPlaceholder: const Text('Pesquisar formulário...'),
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhum formulário encontrado'),
                      ),
                      builder: (context, searchQuery) {
                        final query = searchQuery?.toLowerCase() ?? '';
                        final filtered = widget.availableFormularyList
                            .where((form) => form.title.toLowerCase().contains(query))
                            .toList();
                        return SelectItemList(
                          children: filtered
                              .map((form) => SelectItemButton(value: form, child: Text(form.title)))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),
          FxDivider(title: 'Cliente Associado (Opcional)', icon: Symbols.business),
          Row(
            children: [
              Expanded(
                child: FormField<ClientModel>(
                  key: _clientKey,
                  label: const Text('Cliente'),
                  child: Select<ClientModel>(
                    value: widget.model.client,
                    placeholder: const Text('Nenhum cliente selecionado'),
                    itemBuilder: (context, client) => Text(client.name),
                    onChanged: (client) {
                      setState(() {
                        widget.model.client = client;
                      });
                    },
                    popup: (context) => SelectPopup.builder(
                      searchPlaceholder: const Text('Pesquisar cliente...'),
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhum cliente encontrado'),
                      ),
                      builder: (context, searchQuery) {
                        final query = searchQuery?.toLowerCase() ?? '';
                        final filtered = widget.availableClientsList
                            .where((client) => client.name.toLowerCase().contains(query))
                            .toList();
                        return SelectItemList(
                          children: filtered
                              .map((client) => SelectItemButton(value: client, child: Text(client.name)))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap(148),
        ],
      ),
    );
  }
}
