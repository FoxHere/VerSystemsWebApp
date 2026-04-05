import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/ui/shared/lists/components/form_list_empty.dart';

class AppPageStatusBuilder<T> extends StatelessWidget {
  const AppPageStatusBuilder({
    super.key,
    required this.pageStatus,
    required this.successBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.onRetry,
    this.emptyWidget,
  });

  final PageStatus pageStatus;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget Function(T) successBuilder;
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      reverseDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 1),
      child: switch (pageStatus) {
        PageStatusIdle _ => Container(),
        PageStatusLoading _ => (loadingWidget != null) ? loadingWidget! : Center(child: CircularProgressIndicator()),
        PageStatusError status =>
          (errorWidget != null)
              ? errorWidget!
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${status.message}'),
                      if (onRetry != null) TextButton(onPressed: onRetry, child: Text('Retry')),
                    ],
                  ),
                ),
        // Modificar o empty depois criando os campos de empty necessários
        PageStatusEmpty message =>
          emptyWidget != null ? emptyWidget! : FormListEmpty(title: message.title, description: message.description, action: message.action),
        PageStatusSuccess status => successBuilder(status.data),
      },
    );
  }
}
