import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/data/models/client/client_model.dart';
import 'package:versystems_app/ui/modules/client_manager/client_form/client_manager_view_model.dart';
import 'package:versystems_app/ui/modules/client_manager/client_form/components/client_form.dart';

class ClientManagerView extends StatefulWidget {
  final String clientId;

  const ClientManagerView({super.key, required this.clientId});

  @override
  State<ClientManagerView> createState() => _ClientManagerViewState();
}

class _ClientManagerViewState extends State<ClientManagerView> with SingleTickerProviderStateMixin, MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<ClientManagerViewModel>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final formWidgetKey = GlobalKey<ClientFormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initialize(widget.clientId);
    });

    messageListener(viewModel);
    // viewModel.addListener(() {
    //   Future.microtask(() {
    //     if (mounted) setState(() {});
    //   });
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    final theme = Theme.of(context);

    return Scaffold(
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
                color: theme.colorScheme.background,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.clientId == 'new' ? 'Novo Cliente' : 'Editar Cliente').h3(),
                        Text('Gerencie os detalhes do cliente.').muted().small(),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      SecondaryButton(
                        onPressed: () => context.go(RoutesHelper.clients),
                        child: const Row(spacing: 8, children: [Icon(Symbols.arrow_back, size: 18), Text('Voltar')]),
                      ),
                      PrimaryButton(
                        onPressed: () async {
                          final formState = formWidgetKey.currentState;
                          if (formState != null && formState.validateForm()) {
                            final clientForm = formState.clientModel;
                            await viewModel.onSaveClient(clientForm);
                            if (viewModel.pageStatus.value is PageStatusSuccess && context.mounted) {
                              context.go(RoutesHelper.clients);
                            }
                          }
                        },
                        child: Obx(() {
                          final isLoading = viewModel.pageStatus.value is PageStatusLoading;
                          return Row(
                            spacing: 8,
                            children: [
                              if (isLoading) const CircularProgressIndicator(size: 16) else const Icon(Symbols.save, size: 18),
                              Text(isLoading ? 'Salvando...' : 'Salvar'),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content Area
            Expanded(
              child: Obx(() {
                return AppPageStatusBuilder<ClientModel>(
                  pageStatus: viewModel.pageStatus.value,
                  successBuilder: (clientModel) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ClientForm(key: formWidgetKey, model: clientModel),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
