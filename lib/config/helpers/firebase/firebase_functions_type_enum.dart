/// Enum que define todas as funções disponíveis no Firebase Functions
enum FirebaseFunctionTypeEnum {
  /// Funcção para criar usuário Auth
  createAuthUser('createAuthUser'),

  /// Funcção para deletar usuário Auth
  deleteAuthUser('deleteAuthUser'),

  /// Funcção para alterar status do usuário Auth
  changeAuthUser('changeAuthUser'),

  /// Funcção para inicializar dashboard com dados existentes
  initializeDashboard('initializeDashboard');

  const FirebaseFunctionTypeEnum(this.functionName);

  /// Nome da função no Firebase Functions
  final String functionName;

  /// Retorna o enum baseado no nome da função
  static FirebaseFunctionTypeEnum? fromString(String functionName) {
    try {
      return FirebaseFunctionTypeEnum.values.firstWhere(
        (type) => type.functionName == functionName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Retorna todos os nomes das funções disponíveis
  static List<String> getAllFunctionNames() {
    return FirebaseFunctionTypeEnum.values.map((type) => type.functionName).toList();
  }
}
