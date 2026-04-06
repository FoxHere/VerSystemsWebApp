import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status_builder.dart';
import 'package:versystems_app/ui/modules/dashboard/dashboard_view_model.dart';
import 'package:versystems_app/data/models/dashboard/dashboard_model.dart';
import 'package:versystems_app/ui/modules/dashboard/components/dashboard_metric_card.dart';
import 'package:versystems_app/ui/modules/dashboard/components/dashboard_quick_actions.dart';

class DashboardView extends StatefulWidget {
  final String dashboardId;

  const DashboardView({super.key, required this.dashboardId});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin, MessageViewMixin, ResponsiveDeviceMixin {
  final dashboardViewModel = Get.find<DashboardViewModel>();
  final authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardViewModel.findAllDashboardData(widget.dashboardId);
    });
    messageListener(dashboardViewModel);
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    _animationController.reset();
    dashboardViewModel.findAllDashboardData(widget.dashboardId).then((_) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();

    return Obx(
      () => AppPageStatusBuilder<DashboardModel>(
        pageStatus: dashboardViewModel.pageStatus.value,
        successBuilder: (dashboard) {
          final currentUserId = authController.localUserModel.value?.id;
          final currentUserTasks = dashboard.pendentTasks?.users.firstWhereOrNull((u) => u?.user == currentUserId);

          int pendingTasksTotal = currentUserTasks?.props.total ?? 0;
          int pendingTasksMonth = currentUserTasks?.props.totalThisMonth ?? 0;
          // return Container();

          return FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_animation),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: CustomScrollView(
                  // padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(child: _buildMetricsGrid(dashboard, pendingTasksTotal, pendingTasksMonth)),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: const DashboardQuickActions()),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: _buildRecentTasksSection(pendingTasksTotal)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final userName = authController.localUserModel.value?.name ?? 'Usuário';
    final firstName = userName.split(' ').first;
    final currentCompany = dashboardViewModel.currentCompanyName.value;
    final companyText = currentCompany.isNotEmpty ? currentCompany : 'nossa plataforma';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá $firstName, seja bem-vindo(a) a $companyText!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text('Aqui está o resumo do seu sistema hoje.', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.mutedForeground)),
            ],
          ),
        ),
        OutlineButton(
          onPressed: _refreshDashboard,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(LucideIcons.refreshCw, size: 16), const SizedBox(width: 8), const Text('Atualizar')],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(DashboardModel dashboard, int pendingTasksTotal, int pendingTasksMonth) {
    List<Widget> cards = [
      DashboardMetricCard(
        title: 'Total de Formulários',
        indicator: dashboard.formularies?.total ?? 0,
        subTitle: '+${dashboard.formularies?.totalThisMonth ?? 0} desde o último mês',
        icon: LucideIcons.fileText,
        iconColor: Colors.blue.shade500,
      ),
      DashboardMetricCard(
        title: 'Atividades',
        indicator: dashboard.activities?.total ?? 0,
        subTitle: '+${dashboard.activities?.totalThisMonth ?? 0} desde o último mês',
        icon: LucideIcons.check,
        iconColor: Colors.green.shade500,
      ),
      DashboardMetricCard(
        title: 'Membros do Time',
        indicator: dashboard.members?.total ?? 0,
        subTitle: '+${dashboard.members?.totalThisMonth ?? 0} desde o último mês',
        icon: LucideIcons.users,
        iconColor: Colors.purple.shade500,
      ),
      DashboardMetricCard(
        title: 'Tarefas Pendentes',
        indicator: pendingTasksTotal,
        subTitle: '+$pendingTasksMonth desde o último mês',
        icon: LucideIcons.clock,
        iconColor: Colors.amber.shade500,
      ),
    ];

    if (isLargeScreen) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(padding: const EdgeInsets.only(right: 16.0), child: c),
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        children: cards
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(width: double.infinity, child: c),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildRecentTasksSection(int pendingTasksTotal) {
    if (pendingTasksTotal == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(LucideIcons.check, size: 48, color: Colors.green.shade500),
                const SizedBox(height: 16),
                const Text('Tudo em dia!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Você não tem tarefas pendentes no momento.', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Aviso de Tarefas Pendentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                OutlineBadge(child: Text('$pendingTasksTotal')),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Você tem $pendingTasksTotal tarefas aguardando sua ação. Acesse o módulo de tarefas para visualizá-las.',
              style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
