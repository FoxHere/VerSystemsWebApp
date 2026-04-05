import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/profile/profile_status.dart';
import 'package:versystems_app/ui/shared/components/divider/fx_divider.dart';

class ProfileForm extends StatefulWidget {
  final ProfileModel model;

  const ProfileForm({super.key, required this.model});

  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  final FormController _formController = FormController();

  final _nameKey = const FormKey<String>(#name);
  final _descriptionKey = const FormKey<String>(#description);
  final _levelKey = const FormKey<String>(#level);
  final _allowedMenusKey = const FormKey<Iterable<String>>(#allowedMenus);

  final List<String> availableMenus = [
    "/dashboard",
    "/activities",
    "/settings",
    "/formularies",
    "/tasks",
    "/profiles",
    "/departments",
    "/users",
    "/clients",
    "/companies",
  ];

  late List<String> _currentAllowedMenus;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _currentAllowedMenus = List.from(widget.model.allowedMenus);
    _isActive = widget.model.profileStatus == ProfileStatusEnum.active;
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

  ProfileModel get profileModel {
    return widget.model.copyWith(
      name: _formController.getValue(_nameKey) ?? widget.model.name,
      description:
          _formController.getValue(_descriptionKey) ?? widget.model.description,
      level:
          int.tryParse(_formController.getValue(_levelKey) ?? '') ??
          widget.model.level,
      allowedMenus:
          _formController.getValue(_allowedMenusKey)?.toList() ??
          _currentAllowedMenus,
      profileStatus: _isActive ? ProfileStatusEnum.active : ProfileStatusEnum.inactive,
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
          const FxDivider(
            title: 'Dados do Perfil',
            icon: Symbols.manage_accounts,
          ),
          
          Row(
            spacing: 12,
            children: [
              const Text('Perfil Ativo:').small().muted(),
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
                  label: const Text('Nome do Perfil'),
                  validator: const NotEmptyValidator(
                    message: 'Nome obrigatório',
                  ),
                  child: TextField(
                    initialValue: widget.model.name,
                    placeholder: const Text('Administrador, Operador, etc.'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FormField<String>(
                  key: _levelKey,
                  label: const Text('Nível de Acesso (Ex: 0 a 100)'),
                  validator: const NotEmptyValidator(
                    message: 'Nível é obrigatório',
                  ),
                  child: TextField(
                    initialValue: widget.model.level.toString(),
                    placeholder: const Text('ex: 50'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ).paddingOnly(bottom: 24),

          FormField<String>(
            key: _descriptionKey,
            label: const Text('Descrição / Detalhes'),
            child: TextArea(
              initialValue: widget.model.description,
              placeholder: const Text(
                'Descreva as atribuições deste perfil...',
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ).paddingOnly(bottom: 24),

          const FxDivider(
            title: 'Permissões e Menus',
            icon: Symbols.format_list_bulleted,
          ),

          FormField<Iterable<String>>(
            key: _allowedMenusKey,
            label: const Text('Menus Permitidos'),
            child: MultiSelect<String>(
              value: _currentAllowedMenus,
              placeholder: const Text('Selecione os módulos liberados...'),
              onChanged: (values) {
                if (values != null) {
                  setState(() {
                    _currentAllowedMenus = values.toList();
                  });
                }
              },
              itemBuilder: (context, menuPath) {
                return Text(
                  menuPath.replaceAll('/', '').capitalizeFirst ?? menuPath,
                );
              },
              popup: (context) => SelectPopup(
                items: SelectItemList(
                  children: availableMenus.map((menuPath) {
                    return SelectItemButton(
                      value: menuPath,
                      child: Text(
                        menuPath.replaceAll('/', '').capitalizeFirst ??
                            menuPath,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ).paddingOnly(bottom: 48),
        ],
      ),
    );
  }
}
