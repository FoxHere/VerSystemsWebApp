import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/company/company_address_model.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/company/company_status.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class CompanyForm extends StatefulWidget {
  final CompanyModel model;
  final bool hideAssignments;

  const CompanyForm({super.key, required this.model, this.hideAssignments = false});

  @override
  State<CompanyForm> createState() => CompanyFormState();
}

class CompanyFormState extends State<CompanyForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _tradeNameKey = const FormKey<String>(#tradeName);
  final _cnpjKey = const FormKey<String>(#cnpj);
  final _stateRegistrationKey = const FormKey<String>(#stateRegistration);
  final _municipalRegistrationKey = const FormKey<String>(#municipalRegistration);

  final _emailKey = const FormKey<String>(#email);
  final _phoneKey = const FormKey<String>(#phone);
  final _websiteKey = const FormKey<String>(#website);

  final _streetKey = const FormKey<String>(#street);
  final _numberKey = const FormKey<String>(#number);
  final _complementKey = const FormKey<String>(#complement);
  final _neighborhoodKey = const FormKey<String>(#neighborhood);
  final _cityKey = const FormKey<String>(#city);
  final _stateKey = const FormKey<String>(#state);
  final _zipCodeKey = const FormKey<String>(#zipCode);

  final _notesKey = const FormKey<String>(#notes);

  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.model.companyStatus == CompanyStatusEnum.active;
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

  CompanyModel get companyModel {
    final address = CompanyAddressModel(
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
      tradeName: _formController.getValue(_tradeNameKey) ?? widget.model.tradeName,
      cnpj: _formController.getValue(_cnpjKey) ?? widget.model.cnpj,
      stateRegistration: _formController.getValue(_stateRegistrationKey) ?? widget.model.stateRegistration,
      municipalRegistration: _formController.getValue(_municipalRegistrationKey) ?? widget.model.municipalRegistration,
      email: _formController.getValue(_emailKey) ?? widget.model.email,
      phone: _formController.getValue(_phoneKey) ?? widget.model.phone,
      website: _formController.getValue(_websiteKey) ?? widget.model.website,
      notes: _formController.getValue(_notesKey) ?? widget.model.notes,
      companyStatus: _isActive ? CompanyStatusEnum.active : CompanyStatusEnum.inactive,
      isActive: _isActive, // keep backward compatibility
      addresses: [address],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstAddress = widget.model.addresses.isNotEmpty ? widget.model.addresses.first : CompanyAddressModel.empty();

    return Form(
      controller: _formController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FxDivider(title: 'Identidade e Fiscal', icon: Symbols.business),
          if (!widget.hideAssignments)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    const Text('Empresa Ativa:').small().muted(),
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
                  label: const Text('Razão Social'),
                  validator: const NotEmptyValidator(message: 'A Razão Social é obrigatória'),
                  child: TextField(initialValue: widget.model.name, placeholder: const Text('Digite a razão social...')),
                ),
              ),
              Expanded(
                flex: 2,
                child: FormField<String>(
                  key: _tradeNameKey,
                  label: const Text('Nome Fantasia'),
                  child: TextField(initialValue: widget.model.tradeName ?? '', placeholder: const Text('Digite o nome fantasia...')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _cnpjKey,
                  label: const Text('CNPJ'),
                  validator: const NotEmptyValidator(message: 'O CNPJ é obrigatório'),
                  child: TextField(initialValue: widget.model.cnpj, placeholder: const Text('00.000.000/0000-00')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<String>(
                  key: _stateRegistrationKey,
                  label: const Text('Inscrição Estadual'),
                  child: TextField(initialValue: widget.model.stateRegistration ?? '', placeholder: const Text('Isento ou número da IE')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _municipalRegistrationKey,
                  label: const Text('Inscrição Municipal'),
                  child: TextField(initialValue: widget.model.municipalRegistration ?? '', placeholder: const Text('Isento ou número da IM')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Contato', icon: Symbols.contact_mail),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<String>(
                  key: _emailKey,
                  label: const Text('E-mail Principal'),
                  child: TextField(initialValue: widget.model.email ?? '', placeholder: const Text('exemplo@empresa.com.br')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _phoneKey,
                  label: const Text('Telefone / WhatsApp'),
                  child: TextField(initialValue: widget.model.phone ?? '', placeholder: const Text('(00) 00000-0000')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _websiteKey,
                  label: const Text('Site Oficial'),
                  child: TextField(initialValue: widget.model.website ?? '', placeholder: const Text('https://www.empresa.com.br')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Endereço Sede', icon: Symbols.location_on),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: FormField<String>(
                  key: _streetKey,
                  label: const Text('Logradouro (Rua, Av.)'),
                  child: TextField(initialValue: firstAddress.street, placeholder: const Text('Av. Paulista, etc.')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _numberKey,
                  label: const Text('Número'),
                  child: TextField(initialValue: firstAddress.number, placeholder: const Text('1000')),
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
                  child: TextField(initialValue: firstAddress.complement, placeholder: const Text('Sala, Andar, etc.')),
                ),
              ),
              Expanded(
                flex: 2,
                child: FormField<String>(
                  key: _neighborhoodKey,
                  label: const Text('Bairro'),
                  child: TextField(initialValue: firstAddress.neighborhood, placeholder: const Text('Bela Vista...')),
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
                  child: TextField(initialValue: firstAddress.city, placeholder: const Text('São Paulo')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _stateKey,
                  label: const Text('Estado/UF'),
                  child: TextField(initialValue: firstAddress.state, placeholder: const Text('SP')),
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
                  label: const Text('Anotações'),
                  child: TextArea(
                    initialValue: widget.model.notes ?? '',
                    placeholder: const Text('Insira detalhes adicionais sobre o contrato ou especificações da empresa.'),
                    minLines: 3,
                    maxLines: 6,
                  ),
                ),
              ),
            ],
          ).paddingOnly(bottom: 48),
        ],
      ),
    );
  }
}
