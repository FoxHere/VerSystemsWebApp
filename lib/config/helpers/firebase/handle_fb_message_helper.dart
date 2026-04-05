import 'package:firebase_core/firebase_core.dart';

class HandleFbMessageHelper {
  static String handleFBException(FirebaseException e) {
    switch (e.code) {
      case 'cancelled':
        return 'Operação cancelada pelo sistema.';
      case 'unknown':
        return 'Ocorreu um erro desconhecido.';
      case 'wrong-password':
        return 'Usuário ou Senha incorretos.';
      case 'user-not-found':
        return 'Usuário ou Senha incorretos.';
      case 'invalid-argument':
        return 'Argumento inválido fornecido. Verifique os dados.';
      case 'deadline-exceeded':
        return 'O tempo limite da operação foi excedido.';
      case 'not-found':
        return 'O recurso solicitado não foi encontrado.';
      case 'already-exists':
        return 'O recurso já existe.';
      case 'permission-denied':
        return 'Permissão negada para acessar este recurso.';
      case 'unauthenticated':
        return 'Você precisa estar autenticado para acessar este recurso.';
      case 'resource-exhausted':
        return 'Os recursos foram excedidos. Tente novamente mais tarde.';
      case 'failed-precondition':
        return 'Condição inválida para executar a operação.';
      case 'aborted':
        return 'Operação abortada. Tente novamente.';
      case 'out-of-range':
        return 'Valor fora do intervalo permitido.';
      case 'unimplemented':
        return 'Operação não implementada.';
      case 'internal':
        return 'Erro interno no sistema.';
      case 'unavailable':
        return 'Serviço indisponível no momento. Tente novamente mais tarde.';
      case 'data-loss':
        return 'Erro crítico. Dados foram perdidos.';
      default:
        return 'Erro desconhecido: ${e.message}';
    }
  }
}
