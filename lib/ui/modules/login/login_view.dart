import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide FormState;
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/controllers/theme/theme_controller.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/gen/assets.gen.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/helpers/strings/app_strings_helper.dart';
import 'package:versystems_app/ui/modules/login/login_view_model.dart';

class LoginView extends StatefulWidget {
  final String? redirectTo;
  const LoginView({super.key, this.redirectTo});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with MessageViewMixin, ResponsiveDeviceMixin, SingleTickerProviderStateMixin {
  final viewModel = Get.find<LoginViewModel>();
  final authController = Get.find<AuthController>();
  final themeController = Get.find<ThemeController>();

  final _emailKey = const TextFieldKey('email');
  final _passwordKey = const TextFieldKey('password');
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final validatingForm = false.obs;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    _loadAppVersion();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
        });
      }
    }
  }

  Future<void> _submitForm(BuildContext context, Map<FormKey<dynamic>, dynamic> values) async {
    String email = values[_emailKey] as String;
    String password = values[_passwordKey] as String;
    validatingForm(true);
    // await Future.delayed(Duration(seconds: 2));
    final result = await viewModel.login(email, password);
    if (result is Right) {
      await authController.initializeIt();
      if (context.mounted) {
        context.go(widget.redirectTo ?? RoutesHelper.dashboard);
      }
    }
    validatingForm(false);
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    final currentYear = DateTime.now().year;

    return Scaffold(
      footers: [
        Padding(
          padding: const EdgeInsets.all(Boudaries.spacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© $currentYear VerSystems'
                '${_appVersion.isNotEmpty ? ' • v$_appVersion' : ''}',
              ).light.small(color: Colors.slate),
              Obx(() {
                return Switch(
                  leading: const Icon(Icons.dark_mode),
                  trailing: const Icon(Icons.light_mode),
                  value: !themeController.isDarkMode,
                  onChanged: (value) {
                    themeController.toggleThemeMode();
                  },
                );
              }),
            ],
          ),
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: (isLargeScreen || isMediumScreen) ? 480 : 350,
            child: Form(
              onSubmit: (context, values) async {
                await _submitForm(context, values);
              },
              child: Builder(
                builder: (formContext) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Assets.images.common.logos.logo01.image(height: 60, fit: BoxFit.contain),
                      const Gap(8),
                      Text(AppStringsHelper.loginSubtitle).light(color: Colors.slate),
                      Gap(Boudaries.spacing),
                      Card(
                        padding: const EdgeInsets.all(Boudaries.spacing),
                        borderColor: Colors.slate.shade200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStringsHelper.loginTitle).x2Large.semiBold,
                                Text(AppStringsHelper.loginSubtitle).light.small(color: Colors.slate),
                              ],
                            ),
                            Focus(
                              onKeyEvent: (node, event) {
                                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
                                  _passwordFocusNode.requestFocus();
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: FormField(
                                key: _emailKey,
                                validator: EmailValidator(message: 'E-mail inválido'),
                                label: Text(AppStringsHelper.loginFieldEmail),
                                child: TextField(
                                  focusNode: _emailFocusNode,
                                  placeholder: Text(AppStringsHelper.loginFieldEmailHint),
                                  autocorrect: true,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) {
                                    _passwordFocusNode.requestFocus();
                                  },
                                  features: [
                                    InputFeature.clear(),
                                    InputFeature.leading(Icon(Icons.email, color: Colors.slate.shade400)),
                                  ],
                                ),
                              ),
                            ),
                            FormField(
                              key: _passwordKey,
                              showErrors: const {FormValidationMode.changed},
                              validator: LengthValidator(min: 8, message: 'Mínimo de 8 caracteres'),
                              label: Text(AppStringsHelper.loginFieldPassword),
                              child: TextField(
                                focusNode: _passwordFocusNode,
                                placeholder: Text(AppStringsHelper.loginFieldPasswordHint),
                                obscureText: true,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) {
                                  formContext.submitForm();
                                },
                                features: [
                                  InputFeature.passwordToggle(mode: PasswordPeekMode.toggle),
                                  InputFeature.leading(Icon(Icons.lock, color: Colors.slate.shade400)),
                                ],
                              ),
                            ),
                            FormErrorBuilder(
                              builder: (context, error, child) {
                                return Obx(() {
                                  final bool isLoading = validatingForm.value || viewModel.isLoading.value;
                                  final Widget icon = isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Icon(Symbols.login, color: Colors.white);
                                  final String label = isLoading ? 'Validando...' : AppStringsHelper.loginLoginBtn;
                                  return PrimaryButton(
                                    density: ButtonDensity.normal,
                                    onPressed: error.isEmpty && !isLoading ? () => context.submitForm() : null,
                                    child: Row(
                                      spacing: 5,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        icon,
                                        Text(label).normal(color: Colors.white),
                                      ],
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        ).gap(Boudaries.spacing),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    // return FadeTransition(
    //   opacity: _animation,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Assets.images.common.logos.logo01.image(height: 42, fit: BoxFit.fill),
    //       backgroundColor: Colors.white,
    //     ),
    //     body: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           spacing: 100,
    //           children: [
    //             if (isLargeScreen)
    //               Padding(
    //                 padding: FxTheme.padding,
    //                 child: Assets.images.views.login.login.image(height: 500, fit: BoxFit.fill),
    //               ),
    //             Center(
    //               child: Column(
    //                 spacing: 10,
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Text(
    //                     AppStringsHelper.loginTitle,
    //                     style: Theme.of(context).textTheme.titleLarge,
    //                   ),
    //                   Text(
    //                     AppStringsHelper.loginSubtitle,
    //                     style: TextStyle(color: Colors.blueGrey),
    //                   ),
    //                   SizedBox(
    //                     width: 430,
    //                     child: FxCard(
    //                       child: Padding(
    //                         padding: FxTheme.padding,
    //                         child: Column(
    //                           spacing: 20,
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             Form(
    //                               key: formKey,
    //                               child: Column(
    //                                 children: [
    //                                   FxTextFormField(
    //                                     controller: _emailEC,
    //                                     label: AppStringsHelper.loginFieldEmail,
    //                                     hasTopLabel: true,
    //                                     hint: AppStringsHelper.loginFieldEmailHint,
    //                                     validator: Validatorless.multiple([
    //                                       Validatorless.required('O e-mail é obrigatório'),
    //                                       Validatorless.email('E-mail inválido'),
    //                                     ]),
    //                                   ),
    //                                   Obx(() {
    //                                     return FxTextFormField(
    //                                       controller: _passwordEC,
    //                                       maxLines: 1,
    //                                       label: AppStringsHelper.loginFieldPassword,
    //                                       hint: AppStringsHelper.loginFieldPasswordHint,
    //                                       suffixTitle: TextButton(
    //                                         onPressed: () {},
    //                                         child: Text(AppStringsHelper.loginForgotPassword),
    //                                       ),
    //                                       hasTopLabel: true,
    //                                       obscureText: passwordFieldObscure.value,
    //                                       suffixIcon: passwordFieldObscure.value
    //                                           ? Symbols.visibility
    //                                           : Symbols.visibility_off,
    //                                       onSuffixTap: () => passwordFieldObscure.value =
    //                                           !passwordFieldObscure.value,
    //                                       validator: Validatorless.multiple([
    //                                         Validatorless.required('A Senha é obrigatória'),
    //                                         Validatorless.min(8, 'O mínimo de caracteres é 8'),
    //                                       ]),
    //                                     );
    //                                   }),
    //                                 ],
    //                               ),
    //                             ),
    //                             Obx(() {
    //                               return FxCheckbox(
    //                                 label: AppStringsHelper.loginRememberMe,
    //                                 value: rememberMe.value,
    //                                 onChanged: (value) => rememberMe.value = !rememberMe.value,
    //                               );
    //                             }),
    //                             Obx(() {
    //                               return FxButton(
    //                                 fullWidth: true,
    //                                 size: FxButtonSize.lg,
    //                                 label: AppStringsHelper.loginLoginBtn,
    //                                 isLoading: loginViewModel.isLoading.value,
    //                                 onPressed: () async {
    //                                   if (formKey.currentState?.validate() ?? false) {
    //                                     final result = await loginViewModel.login(
    //                                       _emailEC.text,
    //                                       _passwordEC.text,
    //                                     );
    //                                     if (result is Right) {
    //                                       await authController.initializeIt();
    //                                       if (context.mounted) {
    //                                         context.go(widget.redirectTo ?? RoutesHelper.dashboard);
    //                                       }
    //                                     }
    //                                   }
    //                                 },
    //                               );
    //                             }),
    //                             Row(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [
    //                                 Text(AppStringsHelper.loginNoAccount1),
    //                                 TextButton(
    //                                   onPressed: () {},
    //                                   child: Text(AppStringsHelper.loginNoAccount2),
    //                                 ),
    //                               ],
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
