
import 'package:cloud_functions/cloud_functions.dart';
import 'package:versystems_app/config/helpers/firebase/handle_fb_message_helper.dart';

/// Trata exceções específicas do Firebase Functions
/// [FirebaseFunctionsException] é a exceção específica do Firebase Functions
/// [e] é a exceção a ser tratada
/// [return] é a mensagem de erro a ser retornada
/// [default] é a mensagem de erro padrão

class HandleFbFunctionsExceptionHelper {
  static String handleFirebaseFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'functions/unavailable':
        return 'Serviço de funções não disponível no momento. Tente novamente mais tarde.';
      case 'functions/deadline-exceeded':
        return 'Tempo limite excedido. A função demorou muito para responder.';
      case 'functions/resource-exhausted':
        return 'Recursos esgotados. Tente novamente mais tarde.';
      case 'functions/unauthenticated':
        return 'Usuário não autenticado. Faça login novamente.';
      case 'functions/permission-denied':
        return 'Permissão negada. Você não tem acesso a esta função.';
      case 'functions/not-found':
        return 'Função não encontrada. Verifique se a função existe.';
      case 'functions/already-exists':
        return 'Recurso já existe.';
      case 'functions/failed-precondition':
        return 'Condição prévia não atendida.';
      case 'functions/aborted':
        return 'Operação foi abortada.';
      case 'functions/out-of-range':
        return 'Valor fora do intervalo permitido.';
      case 'functions/unimplemented':
        return 'Função não implementada.';
      case 'functions/internal':
        return 'Erro interno do servidor.';
      case 'functions/data-loss':
        return 'Perda de dados.';
      default:
        return HandleFbMessageHelper.handleFBException(e);
    }
  }
}
