import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_device_mixin.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/helpers/strings/app_strings_helper.dart';
import 'package:versystems_app/data/models/activity/activity_status.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view_model.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_actions.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_description.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_status.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_title.dart';
import 'package:versystems_app/ui/shared/lists/components/table_columns/tc_widget.dart';
import 'package:versystems_app/ui/shared/lists/fx_app_list_widget.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> with MessageViewMixin, ResponsiveDeviceMixin {
  final viewModel = Get.find<TaskListViewModel>();

  @override
  void initState() {
    super.initState();
    messageListener(viewModel);
    viewModel.addListener(() {
      Future.microtask(() => setState(() {}));
    });
  }

  void onRefresh() {
    viewModel.findAllTasks({'userId': viewModel.currentUserId});
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize();
    return FxAppListWidget<ActivityModel>(
      screenSize: isSmallScreen
          ? ScreenSize.isSmallScreen
          : isMediumScreen
          ? ScreenSize.isMediumScreen
          : ScreenSize.isLargeScreen,
      pageStatus: viewModel.pageStatus,
      showStatusTab: true,
      listTitle: AppStringsHelper.taskListHeader,
      listSubtitle: AppStringsHelper.taskListSubtitle,
      searchHint: 'Buscar tarefa...',
      statusList: [
        ActivityStatusVisual(ActivityStatusEnum.active, isTask: true),
        ActivityStatusVisual(ActivityStatusEnum.editing),
        ActivityStatusVisual(ActivityStatusEnum.done),
      ],
      statusFilterFunction: (_) {},
      onViewChange: (_) {},
      searchTextFunction: (value) => viewModel.filterTasks(value),
      onRefresh: onRefresh,
      statusSelector: (item) => item.taskStatus,
      onItemClicked: (item) => context.go('${RoutesHelper.tasks}/${item.id}'),
      items: viewModel.filteredTaskModelList,
      columns: [
        AppTableColumnTitle(title: 'Nome', dataSelector: (item) => item.name),
        AppTableColumnDescription(title: 'Instruções', dataSelector: (item) => item.instructions ?? '—'),
        AppTableColumnStatus(title: 'Status', dataSelector: (item) => item.taskStatus),
        AppTableColumnWidget(
          title: 'Formulário',
          dataSelector: (item) => Text(item.formulary?.title ?? '—').xSmall(color: Colors.slate.shade500),
          tableContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.description, size: 16, color: Colors.slate),
              SizedBox(width: 130, child: item),
            ],
          ),
          cardContent: (item) => Row(
            spacing: 5,
            children: [
              Icon(Symbols.description, size: 16, color: Colors.slate),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 90, child: content),
        ),
        AppTableColumnWidget(
          title: 'Responsável',
          dataSelector: (item) => Row(
            mainAxisAlignment: .center,
            spacing: 5,
            children: [
              Icon(Symbols.person, size: 16, color: Colors.slate),
              Text(item.responsible?.name ?? '—').xSmall(color: Colors.slate.shade500),
            ],
          ),
          cardPosition: (content) => Positioned(
            left: 15,
            bottom: 15,
            child: Column(crossAxisAlignment: .start, children: [Text('Responsável:').xSmall, content]),
          ),
        ),
        AppTableColumnWidget(
          title: 'Cliente',
          dataSelector: (item) => Row(
            mainAxisAlignment: .center,
            spacing: 5,
            children: [
              Icon(Symbols.person, size: 16, color: Colors.slate),
              Text(item.client?.name ?? 'Sem cliente').xSmall(color: Colors.slate.shade500),
            ],
          ),
          cardPosition: (content) => Positioned(
            right: 15,
            bottom: 15,
            child: Column(crossAxisAlignment: .start, children: [Text('Cliente:').xSmall, content]),
          ),
        ),
        AppTableColumnWidget(
          title: 'Data Limite',
          dataSelector: (item) {
            final DateTime date = item.endDateTime;
            final bool isOverdue = date.isBefore(DateTime.now()) && item.taskStatus.status != ActivityStatusEnum.done;
            final String dateStr = DateFormat('dd/MM/yyyy').format(date);

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Icon(Symbols.calendar_today, size: 14, color: isOverdue ? Colors.red : Colors.slate),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.slate.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      'Atrasada',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            );
          },
          tableContent: (item) => item,
          cardContent: (item) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Text(
                'Vencimento:',
                style: TextStyle(
                  color: Colors.slate.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              item,
            ],
          ),
          cardPosition: (content) => Positioned(left: 15, bottom: 68, child: content),
        ),
        AppTableColumnActions(
          title: 'Ações',
          dataSelector: (item) => [
            AppTableColumnActionPress(
              label: 'Abrir',
              onPressed: (context) => context.go('${RoutesHelper.tasks}/${item.id}'),
              icon: Symbols.open_in_new,
            ),
          ],
        ),
      ],
    );
  }
}
