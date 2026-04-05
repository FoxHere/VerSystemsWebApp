import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide FormState;
import 'package:versystems_app/config/constants/boudaries.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/controllers/theme/theme_controller.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/ui/modules/login/login_view_model.dart';

class LoginView extends StatefulWidget {
  final String? redirectTo;
  const LoginView({super.key, this.redirectTo});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with MessageViewMixin, ResponsiveDeviceMixin, SingleTickerProviderStateMixin {
  final viewModel = Get.find<LoginViewModel>();
  final authController = Get.find<AuthController>();

  final _emailKey = const TextFieldKey('email');
  final _passwordKey = const TextFieldKey('password');
  final validatingForm = false.obs;

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
  }

  final themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return Scaffold(
      footers: [
        Row(
          mainAxisAlignment: .end,
          children: [
            Obx(() {
              return Switch(
                leading: Icon(Icons.dark_mode),
                trailing: Icon(Icons.light_mode),
                value: !themeController.isDarkMode,
                onChanged: (value) {
                  themeController.toggleThemeMode();
                },
              ).withPadding(all: Boudaries.spacing);
            }),
          ],
        ),
      ],
      child: Center(
        child: SizedBox(
          width: (isLargeScreen || isMediumScreen) ? 480 : 350,
          child: Form(
            onSubmit: (context, values) async {
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
            },
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              children: [
                Text('FormBuilder Pro').h1.bold(color: Colors.violet),
                Text('Faça login para acessar o sistema').light(color: Colors.slate),
                Gap(Boudaries.spacing),
                Card(
                  padding: .all(Boudaries.spacing),
                  borderColor: Colors.slate.shade200,
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Column(
                        spacing: 5,
                        crossAxisAlignment: .start,
                        children: [
                          Text('Entrar').x2Large.semiBold,
                          Text('Digite seu e-mail e senha para continuar').light.small(color: Colors.slate),
                        ],
                      ),
                      FormField(
                        key: _emailKey,
                        validator: EmailValidator(message: 'E-mail inválido'),
                        label: const Text('E-mail'),
                        child: TextField(
                          initialValue: 'vitor.lima777@gmail.com',
                          autocorrect: true,
                          keyboardType: TextInputType.emailAddress,
                          features: [
                            InputFeature.clear(),
                            InputFeature.leading(Icon(Icons.email, color: Colors.slate.shade400)),
                          ],
                        ),
                      ),
                      FormField(
                        key: _passwordKey,
                        showErrors: {FormValidationMode.changed},
                        validator: LengthValidator(min: 8, message: 'Mínimo de 8 caractéres'),
                        label: const Text('Senha'),
                        child: TextField(
                          initialValue: '123321789',
                          placeholder: Text('••••••••'),
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          features: [
                            InputFeature.passwordToggle(mode: PasswordPeekMode.toggle),
                            InputFeature.leading(Icon(Icons.lock, color: Colors.slate.shade400)),
                          ],
                        ),
                      ),
                      FormErrorBuilder(
                        builder: (context, error, child) {
                          return Obx(() {
                            final bool isLoading = validatingForm.value;
                            final Widget icon = isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Symbols.login, color: Colors.white);
                            final String label = isLoading ? 'Validando...' : 'Entrar';
                            return PrimaryButton(
                              density: ButtonDensity.normal,
                              onPressed: error.isEmpty
                                  ? isLoading
                                        ? null
                                        : () => context.submitForm()
                                  : null,
                              child: Row(
                                spacing: 5,
                                mainAxisAlignment: .center,
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
