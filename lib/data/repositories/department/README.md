# CRUD de Departamento

Este módulo implementa um CRUD completo para gerenciar departamentos no Firebase, seguindo o padrão arquitetural estabelecido no projeto.

## Estrutura

```
lib/data/
├── models/department/
│   └── department_model.dart          # Modelo de dados do departamento
├── repositories/department/
│   ├── department_repository.dart     # Interface do repositório
│   ├── department_repository_impl.dart # Implementação do repositório
│   └── README.md                      # Esta documentação
├── services/department/
│   ├── department_services.dart       # Interface do serviço
│   └── department_services_impl.dart  # Implementação do serviço
└── examples/
    └── department_crud_example.dart   # Exemplos de uso
```

## Funcionalidades

### ✅ Operações CRUD Completas

- **Create**: Criar novos departamentos
- **Read**: Buscar departamento por ID ou listar todos
- **Update**: Atualizar dados de departamentos existentes
- **Delete**: Remover departamentos

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
final departmentRepository = Get.find<DepartmentRepository>();
```

### 2. Criar um Departamento

```dart
final newDepartment = DepartmentModel(
  id: '', // Será gerado automaticamente
  name: 'Departamento de Tecnologia',
  description: 'Responsável pelo desenvolvimento de software',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final result = await departmentRepository.saveDepartment(newDepartment);
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (unit) => print('Departamento criado com sucesso!'),
);
```

### 3. Buscar Departamento por ID

```dart
final result = await departmentRepository.findOneById('department_id');
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (department) {
    if (department != null) {
      print('Nome: ${department.name}');
      print('Descrição: ${department.description}');
    } else {
      print('Departamento não encontrado');
    }
  },
);
```

### 4. Listar Todos os Departamentos

```dart
final result = await departmentRepository.findAllDepartments({});
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (departments) {
    print('Total: ${departments.length}');
    for (final dept in departments) {
      print('- ${dept.name}: ${dept.description}');
    }
  },
);
```

### 5. Atualizar Departamento

```dart
// Primeiro buscar o departamento
final findResult = await departmentRepository.findOneById('department_id');
await findResult.fold(
  (exception) => print('Erro ao buscar: ${exception.message}'),
  (department) async {
    if (department != null) {
      // Criar versão atualizada
      final updated = DepartmentModel(
        id: department.id,
        name: '${department.name} - Atualizado',
        description: department.description,
        createdAt: department.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Salvar alterações
      final saveResult = await departmentRepository.saveDepartment(updated);
      saveResult.fold(
        (exception) => print('Erro ao atualizar: ${exception.message}'),
        (unit) => print('Atualizado com sucesso!'),
      );
    }
  },
);
```

### 6. Deletar Departamento

```dart
final result = await departmentRepository.deleteDepartment('department_id');
result.fold(
  (exception) => print('Erro: ${exception.message}'),
  (unit) => print('Departamento deletado com sucesso!'),
);
```

## Estrutura do Firebase

Os departamentos são armazenados no Firestore seguindo esta estrutura:

```
branches/{companyId}/departments/{departmentId}
```

### Campos do Documento

- `id`: String (ID do documento)
- `name`: String (Nome do departamento)
- `description`: String (Descrição do departamento)
- `createdAt`: DateTime (Data de criação)
- `updatedAt`: DateTime (Data da última atualização)

## Tratamento de Erros

O sistema utiliza o padrão Either para tratamento robusto de erros:

- **RepositoryException**: Erros no nível do repositório
- **ServiceException**: Erros no nível do serviço (Firebase)
- **Network Errors**: Tratamento de erros de conexão
- **Firebase Errors**: Tratamento específico de erros do Firebase

## Exemplo Completo

Veja o arquivo `lib/data/examples/department_crud_example.dart` para um exemplo completo de todas as operações CRUD.

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