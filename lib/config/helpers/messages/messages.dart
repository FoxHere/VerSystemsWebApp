import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

enum MessageType {
  error,
  info,
  warning,
  success;

  Color get color {
    switch (this) {
      case MessageType.error:
        return Colors.red;
      case MessageType.info:
        return Colors.blue;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.success:
        return Colors.green;
    }
  }

  String get title {
    switch (this) {
      case MessageType.error:
        return 'Erro';
      case MessageType.info:
        return 'Informação';
      case MessageType.warning:
        return 'Aviso';
      case MessageType.success:
        return 'Sucesso';
    }
  }
}

class BuildToastWidget extends StatelessWidget {
  const BuildToastWidget({super.key, required this.context, required this.overlay, this.title, required this.message, required this.type});
  final BuildContext context;
  final ToastOverlay overlay;
  final String message;
  final String? title;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Basic(
        title: Text(title ?? type.title),
        subtitle: Text(message),
        leading: Icon(Icons.info, color: type.color),
        trailing: IconButton.text(
          size: ButtonSize.small,
          onPressed: () {
            overlay.close();
          },
          icon: Icon(Symbols.close),
        ),
      ),
    );
  }
}

// Widget buildToast(BuildContext context, ToastOverlay overlay) {
//   return SurfaceCard(
//     child: Basic(
//       title: const Text('Event has been created'),
//       subtitle: const Text('Sunday, July 07, 2024 at 12:00 PM'),
//       trailing: PrimaryButton(
//         size: ButtonSize.small,
//         onPressed: () {
//           // Close the toast programmatically when clicking Undo.
//           overlay.close();
//         },
//         child: const Text('Fechar'),
//       ),
//       trailingAlignment: Alignment.center,
//     ),
//   );
// }

final class Messages {
  static void showError(String message, BuildContext context) {
    showToast(
      context: context,
      builder: (context, overlay) => BuildToastWidget(context: context, overlay: overlay, message: message, type: MessageType.error),
    );
    // toastification.show(
    //   alignment: Alignment.bottomRight,
    //   context: context,
    //   title: const Text(
    //     'Erro',
    //     style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    //   ),
    //   description: Text(message),
    //   autoCloseDuration: const Duration(seconds: 15),
    //   type: ToastificationType.error,
    // );
  }

  static void showInfo(String message, BuildContext context) {
    showToast(
      context: context,
      builder: (context, overlay) => BuildToastWidget(context: context, overlay: overlay, message: message, type: MessageType.info),
    );
    // toastification.show(
    //   alignment: Alignment.bottomRight,
    //   context: context,
    //   title: const Text(
    //     'Informação',
    //     style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    //   ),
    //   description: Text(message),
    //   autoCloseDuration: const Duration(seconds: 15),
    //   type: ToastificationType.info,
    // );
  }

  static void showSuccess(String message, BuildContext context) {
    showToast(
      context: context,
      builder: (context, overlay) => BuildToastWidget(context: context, overlay: overlay, message: message, type: MessageType.success),
    );
    // toastification.show(
    //   alignment: Alignment.bottomRight,
    //   context: context,
    //   title: const Text(
    //     'Sucesso',
    //     style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
    //   ),
    //   description: Text(message),
    //   autoCloseDuration: const Duration(seconds: 15),
    //   type: ToastificationType.success,
    // );
  }

  static void showWarning(String message, BuildContext context) {
    showToast(
      context: context,
      builder: (context, overlay) => BuildToastWidget(context: context, overlay: overlay, message: message, type: MessageType.warning),
    );
    // toastification.show(
    //   alignment: Alignment.bottomRight,
    //   context: context,
    //   title: const Text(
    //     'Aviso',
    //     style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
    //   ),
    //   description: Text(message),
    //   autoCloseDuration: const Duration(seconds: 15),
    //   type: ToastificationType.warning,
    // );
  }
}

class MessageState {
  final Rx<String?> errorMessage = Rx(null);
  final Rx<String?> infoMessage = Rx(null);
  final Rx<String?> warningMessage = Rx(null);
  final Rx<String?> successMessage = Rx(null);
}

mixin MessageStateMixin {
  final messageState = MessageState().obs;

  void showError(String message) {
    messageState.update((value) {
      value?.errorMessage.value = null;
      value?.infoMessage.value = null;
      value?.warningMessage.value = null;
      value?.successMessage.value = null;

      value?.errorMessage.value = message;
    });
  }

  void showInfo(String message) {
    messageState.update((value) {
      value?.errorMessage.value = null;
      value?.infoMessage.value = null;
      value?.warningMessage.value = null;
      value?.successMessage.value = null;

      value?.infoMessage.value = message;
    });
  }

  void showSuccess(String message) {
    messageState.update((value) {
      value?.errorMessage.value = null;
      value?.infoMessage.value = null;
      value?.warningMessage.value = null;
      value?.successMessage.value = null;

      value?.successMessage.value = message;
    });
  }

  void showWarning(String message) {
    messageState.update((value) {
      value?.errorMessage.value = null;
      value?.infoMessage.value = null;
      value?.warningMessage.value = null;
      value?.successMessage.value = null;

      value?.warningMessage.value = message;
    });
  }
}

mixin MessageViewMixin<T extends StatefulWidget> on State<T> {
  void messageListener(MessageStateMixin state) {
    ever<MessageState>(state.messageState, (messageState) {
      if (messageState.errorMessage.value != null) {
        Messages.showError(messageState.errorMessage.value!, context);
      }
      if (messageState.infoMessage.value != null) {
        Messages.showInfo(messageState.infoMessage.value!, context);
      }
      if (messageState.warningMessage.value != null) {
        Messages.showWarning(messageState.warningMessage.value!, context);
      }
      if (messageState.successMessage.value != null) {
        Messages.showSuccess(messageState.successMessage.value!, context);
      }
    });
  }
}
