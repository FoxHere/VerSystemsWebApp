class StringFormatterHelper {
  /// Formata um CNPJ para o padrão XX.XXX.XXX/XXXX-XX.
  /// Caso seja nulo ou vazio, retorna 'CNPJ não informado'.
  static String formatCnpj(String? cnpj) {
    if (cnpj == null || cnpj.trim().isEmpty) {
      return 'CNPJ não informado';
    }
    final digits = cnpj.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 14) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12, 14)}';
    }
    return cnpj;
  }

  /// Formata um número de telefone/contato para o padrão (XX) 9.XXXX-XXXX ou (XX) XXXX-XXXX.
  /// Caso seja nulo ou vazio, retorna 'Contato não informado'.
  static String formatPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Contato não informado';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 3)}.${digits.substring(3, 7)}-${digits.substring(7, 11)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6, 10)}';
    }
    return phone;
  }

  /// Retorna o e-mail ou 'E-mail não informado' se nulo ou vazio.
  static String formatEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'E-mail não informado';
    }
    return email;
  }

  /// Formata um CEP no padrão 00000-000.
  /// Caso seja nulo ou vazio, retorna 'CEP não informado'.
  static String formatCep(String? cep) {
    if (cep == null || cep.trim().isEmpty) {
      return 'CEP não informado';
    }
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      return '${digits.substring(0, 5)}-${digits.substring(5, 8)}';
    }
    return cep;
  }
}
