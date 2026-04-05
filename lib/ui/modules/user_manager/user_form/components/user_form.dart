import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/company/company_model.dart';
import 'package:versystems_app/data/models/department/department_model.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/user/user_model.dart';
import 'package:versystems_app/data/models/user/user_status.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class UserForm extends StatefulWidget {
  final UserModel model;
  final List<DepartmentModel> availableDepartmentList;
  final List<ProfileModel> availableProfileList;
  final List<CompanyModel> availableCompanyList;

  /// Quando true, oculta e não valida os campos de Departamento e Perfil.
  /// Usado no wizard de setup inicial, onde esses valores são criados automaticamente.
  final bool hideAssignments;

  const UserForm({
    super.key,
    required this.model,
    required this.availableDepartmentList,
    required this.availableProfileList,
    required this.availableCompanyList,
    this.hideAssignments = false,
  });

  @override
  State<UserForm> createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _emailKey = const FormKey<String>(#email);
  final _companyKey = const FormKey<String>(#company);
  final _cpfKey = const FormKey<String>(#cpf);
  final _birthDateKey = const FormKey<String>(#birthDate);
  final _roleKey = const FormKey<String>(#role);

  final _cellphoneKey = const FormKey<String>(#cellphone);

  final _departmentKey = const FormKey<String>(#department);
  final _profileKey = const FormKey<String>(#profile);

  late bool _isActive;
  late DepartmentModel? _selectedDepartment;
  late ProfileModel? _selectedProfile;
  late CompanyModel? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _isActive = widget.model.userStatus == UserStatusEnum.active;

    _selectedDepartment = widget.availableDepartmentList.firstWhereOrNull((d) => d.id == widget.model.department.id);
    _selectedProfile = widget.availableProfileList.firstWhereOrNull((p) => p.id == widget.model.profile.id);
    // Seleciona a empresa pelo ID (campo company contém o branch ID)
    _selectedCompany = widget.availableCompanyList.firstWhereOrNull((c) => c.id == widget.model.company);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  bool validateForm() {
    _formController.revalidate(context, FormValidationMode.submitted);
    // Só valida dept/perfil se não estiver em modo de ocultação
    if (!widget.hideAssignments && (_selectedDepartment == null || _selectedProfile == null)) {
      Get.snackbar('Erro', 'Selecione um Departamento e um Perfil.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (mounted) setState(() {});
    return _formController.errors.isEmpty;
  }

  UserModel get userModel {
    return widget.model.copyWith(
      name: _formController.getValue(_nameKey) ?? widget.model.name,
      email: _formController.getValue(_emailKey) ?? widget.model.email,
      // Armazena o ID da empresa selecionada (branch ID)
      company: _selectedCompany?.id ?? widget.model.company,
      cpf: _formController.getValue(_cpfKey) ?? widget.model.cpf,
      birthDate: _formController.getValue(_birthDateKey) ?? widget.model.birthDate,
      role: _formController.getValue(_roleKey) ?? widget.model.role,
      cellphones: [
        if (_formController.getValue(_cellphoneKey) != null && _formController.getValue(_cellphoneKey)!.isNotEmpty)
          _formController.getValue(_cellphoneKey)!,
      ],
      department: _selectedDepartment ?? widget.model.department,
      profile: _selectedProfile ?? widget.model.profile,
      userStatus: _isActive ? UserStatusEnum.active : UserStatusEnum.inactive,
      isActive: _isActive, // keep backward compatibility
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultCellphone = widget.model.cellphones.isNotEmpty ? widget.model.cellphones.first : '';

    return Form(
      controller: _formController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FxDivider(title: 'Identificação do Usuário', icon: Symbols.person),
          if (!widget.hideAssignments)
            Row(
              spacing: 12,
              children: [
                const Text('Usuário Ativo:').small().muted(),
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
                  label: const Text('Nome Completo'),
                  validator: const NotEmptyValidator(message: 'Nome obrigatório'),
                  child: TextField(initialValue: widget.model.name, placeholder: const Text('Nome do colaborador...')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _cpfKey,
                  label: const Text('CPF'),
                  child: TextField(initialValue: widget.model.cpf ?? '', placeholder: const Text('000.000.000-00')),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _birthDateKey,
                  label: const Text('Data de Nasc.'),
                  child: TextField(initialValue: widget.model.birthDate ?? '', placeholder: const Text('DD/MM/AAAA')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Contato Institucional', icon: Symbols.contact_mail),

          Row(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormField<String>(
                  key: _emailKey,
                  label: const Text('E-mail (Login)'),
                  validator: const NotEmptyValidator(message: 'E-mail obrigatório'),
                  child: TextField(initialValue: widget.model.email, placeholder: const Text('nome@empresa.com.br')),
                ),
              ),
              Expanded(
                child: FormField<String>(
                  key: _cellphoneKey,
                  label: const Text('WhatsApp / Celular'),
                  child: TextField(initialValue: defaultCellphone, placeholder: const Text('(00) 00000-0000')),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          const FxDivider(title: 'Atribuições e Permissões', icon: Symbols.work),

          if (!widget.hideAssignments) ...[
            Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormField<String>(
                    key: _companyKey,
                    label: const Text('Empresa Vinculada'),
                    validator: const NotEmptyValidator(message: 'Selecione a empresa vinculada'),
                    child: Select<String>(
                      value: _selectedCompany?.id,
                      placeholder: const Text('Selecione a empresa...'),
                      onChanged: (val) {
                        setState(() {
                          _selectedCompany = widget.availableCompanyList.firstWhereOrNull((c) => c.id == val);
                        });
                      },
                      itemBuilder: (context, val) {
                        final company = widget.availableCompanyList.firstWhereOrNull((c) => c.id == val);
                        return Text(company?.name ?? val);
                      },
                      popup: (context) => SelectPopup(
                        items: SelectItemList(
                          children: widget.availableCompanyList.map((company) {
                            return SelectItemButton(
                              value: company.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(company.name),
                                  if (company.tradeName != null && company.tradeName!.isNotEmpty) Text(company.tradeName!).muted().xSmall(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FormField<String>(
                    key: _roleKey,
                    label: const Text('Cargo / Função'),
                    child: TextField(initialValue: widget.model.role ?? '', placeholder: const Text('Ex: Analista, Diretor...')),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 24),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: FormField<String>(
                    key: _roleKey,
                    label: const Text('Cargo / Função'),
                    child: TextField(initialValue: widget.model.role ?? '', placeholder: const Text('Ex: Analista, Diretor...')),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 24),
          ],

          if (!widget.hideAssignments) ...[
            Row(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormField<String>(
                    key: _departmentKey,
                    label: const Text('Departamento'),
                    validator: const NotEmptyValidator(message: 'Selecione o departamento'),
                    child: Select<String>(
                      value: _selectedDepartment?.id,
                      placeholder: const Text('Selecione o departamento...'),
                      onChanged: (val) {
                        setState(() {
                          _selectedDepartment = widget.availableDepartmentList.firstWhereOrNull((d) => d.id == val);
                        });
                      },
                      itemBuilder: (context, val) {
                        final dep = widget.availableDepartmentList.firstWhereOrNull((d) => d.id == val);
                        return Text(dep?.name ?? 'Não selecionado');
                      },
                      popup: (context) => SelectPopup(
                        items: SelectItemList(
                          children: widget.availableDepartmentList.map((dep) {
                            return SelectItemButton(value: dep.id, child: Text(dep.name));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FormField<String>(
                    key: _profileKey,
                    label: const Text('Perfil de Acesso (Permissões)'),
                    validator: const NotEmptyValidator(message: 'Selecione o perfil'),
                    child: Select<String>(
                      value: _selectedProfile?.id,
                      placeholder: const Text('Selecione o perfil...'),
                      onChanged: (val) {
                        setState(() {
                          _selectedProfile = widget.availableProfileList.firstWhereOrNull((p) => p.id == val);
                        });
                      },
                      itemBuilder: (context, val) {
                        final prof = widget.availableProfileList.firstWhereOrNull((p) => p.id == val);
                        return Text(prof?.name ?? 'Não selecionado');
                      },
                      popup: (context) => SelectPopup(
                        items: SelectItemList(
                          children: widget.availableProfileList.map((prof) {
                            return SelectItemButton(value: prof.id, child: Text(prof.name));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 48),
          ],
        ],
      ),
    );
  }
}
