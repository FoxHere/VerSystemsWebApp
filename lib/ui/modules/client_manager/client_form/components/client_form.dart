import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/client/client_address_model.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/data/models/client/client_status.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class ClientForm extends StatefulWidget {
  final ClientModel model;

  const ClientForm({super.key, required this.model});

  @override
  State<ClientForm> createState() => ClientFormState();
}

class ClientFormState extends State<ClientForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _emailKey = const FormKey<String>(#email);
  final _phoneKey = const FormKey<String>(#phone);

  final _clientTypeKey = const FormKey<ClientType>(#clientType);
  final _cpfKey = const FormKey<String>(#cpf);
  final _cnpjKey = const FormKey<String>(#cnpj);

  final _notesKey = const FormKey<String>(#notes);

  // Endereço Principal
  final _streetKey = const FormKey<String>(#street);
  final _numberKey = const FormKey<String>(#number);
  final _complementKey = const FormKey<String>(#complement);
  final _neighborhoodKey = const FormKey<String>(#neighborhood);
  final _cityKey = const FormKey<String>(#city);
  final _stateKey = const FormKey<String>(#state);
  final _zipCodeKey = const FormKey<String>(#zipCode);

  final Rx<ClientType> _currentClientType = ClientType.physical.obs;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _currentClientType.value = widget.model.clientType;
    _isActive = widget.model.clientStatus == ClientStatusEnum.active;
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool validateForm() {
    _formController.revalidate(context, FormValidationMode.submitted);
    setState(() {});
    return _formController.errors.isEmpty;
  }

  ClientModel get clientModel {
    final address = ClientAddressModel(
      street: _formController.getValue(_streetKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.street : ''),
      number: _formController.getValue(_numberKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.number : ''),
      complement: _formController.getValue(_complementKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.complement : ''),
      neighborhood:
          _formController.getValue(_neighborhoodKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.neighborhood : ''),
      city: _formController.getValue(_cityKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.city : ''),
      state: _formController.getValue(_stateKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.state : ''),
      zipCode: _formController.getValue(_zipCodeKey) ?? (widget.model.addresses.isNotEmpty ? widget.model.addresses.first.zipCode : ''),
    );

    return widget.model.copyWith(
      name: _formController.getValue(_nameKey) ?? widget.model.name,
      email: _formController.getValue(_emailKey) ?? widget.model.email,
      phone: _formController.getValue(_phoneKey) ?? widget.model.phone,
      clientType: _formController.getValue(_clientTypeKey) ?? widget.model.clientType,
      cpf: _formController.getValue(_cpfKey) ?? widget.model.cpf ?? '',
      cnpj: _formController.getValue(_cnpjKey) ?? widget.model.cnpj ?? '',
      notes: _formController.getValue(_notesKey) ?? widget.model.notes ?? '',
      clientStatus: _isActive ? ClientStatusEnum.active : ClientStatusEnum.inactive,
      addresses: [address],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstAddress = widget.model.addresses.isNotEmpty ? widget.model.addresses.first : ClientAddressModel.empty();

    return Form(
      controller: _formController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FxDivider(title: 'Dados Principais', icon: Symbols.badge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 12,
                children: [
                  const Text('Cliente Ativo:').small().muted(),
                  Switch(
                    value: _isActive,
                    onChanged: (val) {
                      setState(() {
                        _isActive = val;
                      });
                    },
                  ),
                ],
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
                  label: const Text('Nome do Cliente'),
                  validator: const NotEmptyValidator(message: 'Nome é obrigatório'),
                  child: TextField(initialValue: widget.model.name, placeholder: const Text('Digite o nome do cliente...')),
                ),
              ),
              Obx(() {
                final clientType = _currentClientType.value;
                return Expanded(
                  flex: 1,
                  child: FormField<ClientType>(
                    key: _clientTypeKey,
                    label: const Text('Tipo de Cliente'),
                    child: Select<ClientType>(
                      value: clientType,
                      placeholder: const Text('Selecione o tipo'),
                      onChanged: (type) {
                        if (type != null) {
                          _currentClientType.value = type;
                        }
                      },
                      itemBuilder: (context, type) => Text(type == ClientType.physical ? 'Pessoa Física' : 'Pessoa Jurídica'),
                      popup: (context) => SelectPopup(
                        items: SelectItemList(
                          children: [
                            SelectItemButton(value: ClientType.physical, child: const Text('Pessoa Física')),
                            SelectItemButton(value: ClientType.legal, child: const Text('Pessoa Jurídica')),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ).paddingOnly(bottom: 24),

          Obx(() {
            final clientType = _currentClientType.value;
            return IndexedStack(
              index: clientType == ClientType.physical ? 0 : 1,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FormField<String>(
                        key: _cpfKey,
                        label: const Text('CPF'),
                        validator: ConditionalValidator<String>(
                          (value) => _currentClientType.value != ClientType.physical || (value != null && value.isNotEmpty),
                          message: 'CPF é obrigatório',
                          dependencies: [_clientTypeKey],
                        ),
                        child: TextField(initialValue: widget.model.cpf ?? '', placeholder: const Text('000.000.000-00')),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: FormField<String>(
                        key: _cnpjKey,
                        label: const Text('CNPJ'),
                        validator: ConditionalValidator<String>(
                          (value) => _currentClientType.value != ClientType.legal || (value != null && value.isNotEmpty),
                          message: 'CNPJ é obrigatório',
                          dependencies: [_clientTypeKey],
                        ),
                        child: TextField(initialValue: widget.model.cnpj ?? '', placeholder: const Text('00.000.000/0000-00')),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const FxDivider(title: 'Contato', icon: Symbols.contact_mail),
          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<String>(
                  key: _emailKey,
                  label: const Text('E-mail'),
                  validator: const NotEmptyValidator(message: 'E-mail é obrigatório'),
                  child: TextField(initialValue: widget.model.email, placeholder: const Text('exemplo@dominio.com')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _phoneKey,
                  label: const Text('Telefone'),
                  validator: const NotEmptyValidator(message: 'Telefone é obrigatório'),
                  child: TextField(initialValue: widget.model.phone, placeholder: const Text('(00) 00000-0000')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),
          const FxDivider(title: 'Endereço Principal', icon: Symbols.location_on),
          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: FormField<String>(
                  key: _streetKey,
                  label: const Text('Logradouro (Rua, Av.)'),
                  child: TextField(initialValue: firstAddress.street, placeholder: const Text('Rua Exemplo...')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _numberKey,
                  label: const Text('Número'),
                  child: TextField(initialValue: firstAddress.number, placeholder: const Text('123')),
                ),
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
                  key: _complementKey,
                  label: const Text('Complemento'),
                  child: TextField(initialValue: firstAddress.complement, placeholder: const Text('Apto, Bloco, etc.')),
                ),
              ),
              Expanded(
                flex: 2,
                child: FormField<String>(
                  key: _neighborhoodKey,
                  label: const Text('Bairro'),
                  child: TextField(initialValue: firstAddress.neighborhood, placeholder: const Text('Bairro...')),
                ),
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
                  key: _cityKey,
                  label: const Text('Cidade'),
                  child: TextField(initialValue: firstAddress.city, placeholder: const Text('Ex: São Paulo')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _stateKey,
                  label: const Text('Estado/UF'),
                  child: TextField(initialValue: firstAddress.state, placeholder: const Text('Ex: SP')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _zipCodeKey,
                  label: const Text('CEP'),
                  child: TextField(initialValue: firstAddress.zipCode, placeholder: const Text('00000-000')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),
          const FxDivider(title: 'Observações Finais', icon: Symbols.notes),
          Row(
            children: [
              Expanded(
                child: FormField<String>(
                  key: _notesKey,
                  label: const Text('Anotações (Opcional)'),
                  child: TextArea(
                    initialValue: widget.model.notes ?? '',
                    placeholder: const Text('Insira observações relevantes sobre o cliente...'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                ).paddingOnly(bottom: 48),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
