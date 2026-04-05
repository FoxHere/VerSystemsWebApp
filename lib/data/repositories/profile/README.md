# CRUD de Perfil

Este módulo implementa um CRUD completo para gerenciar perfils no Firebase, seguindo o padrão arquitetural estabelecido no projeto.

## Estrutura

```
lib/data/
├── models/profile/
│   └── profile_model.dart          # Modelo de dados do perfil
├── repositories/profile/
│   ├── profile_repository.dart     # Interface do repositório
│   ├── profile_repository_impl.dart # Implementação do repositório
│   └── README.md                      # Esta documentação
├── services/profile/
│   ├── profile_services.dart       # Interface do serviço
│   └── profile_services_impl.dart  # Implementação do serviço
└── examples/
    └── profile_crud_example.dart   # Exemplos de uso
```

## Funcionalidades

### ✅ Operações CRUD Completas

- **Create**: Criar novos perfils
- **Read**: Buscar perfil por ID ou listar todos
- **Update**: Atualizar dados de perfils existentes
- **Delete**: Remover perfils

### 🔧 Características Técnicas

- **Padrão Repository**: Separação clara entre lógica de negócio e acesso a dados
- **Tratamento de Erros**: Uso do padrão Either para tratamento robusto de erros
- **Firebase Integration**: Integração completa com Firestore
- **Type Safety**: Tipagem forte com Dart
- **Dependency Injection**: Integração com GetX para injeção de dependências

## Como Usar

### 1. Injeção de Dependência

As dependências já estão configuradas no `init_dependencies.dart`:

```dart
// O repositório já está disponível via Get.find
final profileRepository = Get.find<profileRepository>();
```

### 2. Criar um Perfil

```dart
final newprofile = profileModel(
  id: '', // Será gerado automaticamente
  name: 'Perfil de Tecnologia',
  description: 'Responsável pelo desenvolvimento de software',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final result = await profileRepository.saveprofile(newprofile);
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (unit) => print('Perfil criado com sucesso!'),
);
```

### 3. Buscar Perfil por ID

```dart
final result = await profileRepository.findOneById('profile_id');
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (profile) {
    if (profile != null) {
      print('Nome: ${profile.name}');
      print('Descrição: ${profile.description}');
    } else {
      print('Perfil não encontrado');
    }
  },
);
```

### 4. Listar Todos os Perfils

```dart
final result = await profileRepository.findAllprofiles({});
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (profiles) {
    print('Total: ${profiles.length}');
    for (final dept in profiles) {
      print('- ${dept.name}: ${dept.description}');
    }
  },
);
```

### 5. Atualizar Perfil

```dart
// Primeiro buscar o perfil
final findResult = await profileRepository.findOneById('profile_id');
await findResult.fold(
  (exception) => print('Erro ao buscar: ${exception.message}'),
  (profile) async {
    if (profile != null) {
      // Criar versão atualizada
      final updated = profileModel(
        id: profile.id,
        name: '${profile.name} - Atualizado',
        description: profile.description,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Salvar alterações
      final saveResult = await profileRepository.saveprofile(updated);
      saveResult.fold(
        (exception) => print('Erro ao atualizar: ${exception.message}'),
        (unit) => print('Atualizado com sucesso!'),
      );
    }
  },
);
```

### 6. Deletar Perfil

```dart
final result = await profileRepository.deleteprofile('profile_id');
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (unit) => print('Perfil deletado com sucesso!'),
);
```

## Estrutura do Firebase

Os perfils são armazenados no Firestore seguindo esta estrutura:

```
branches/{companyId}/profiles/{profileId}
```

### Campos do Documento

- `id`: String (ID do documento)
- `name`: String (Nome do perfil)
- `description`: String (Descrição do perfil)
- `createdAt`: DateTime (Data de criação)
- `updatedAt`: DateTime (Data da última atualização)

## Tratamento de Erros

O sistema utiliza o padrão Either para tratamento robusto de erros:

- **RepositoryException**: Erros no nível do repositório
- **ServiceException**: Erros no nível do serviço (Firebase)
- **Network Errors**: Tratamento de erros de conexão
- **Firebase Errors**: Tratamento específico de erros do Firebase

## Exemplo Completo

Veja o arquivo `lib/data/examples/profile_crud_example.dart` para um exemplo completo de todas as operações CRUD.

## Integração com o Sistema

Este CRUD está totalmente integrado com:

- ✅ Sistema de autenticação
- ✅ Controle de estado (GetX)
- ✅ Injeção de dependências
- ✅ Tratamento de erros padronizado
- ✅ Estrutura de coleções do Firebase

## Próximos Passos

Para usar este CRUD em uma interface de usuário:

1. Criar um ViewModel/Controller
2. Implementar as operações CRUD no ViewModel
3. Conectar com widgets da UI
4. Adicionar validações de dados
5. Implementar feedback visual para o usuário 