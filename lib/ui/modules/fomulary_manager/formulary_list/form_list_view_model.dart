import 'package:get/get.dart';
import 'package:versystems_app/data/models/formulary/formulary_status_enum.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/ui/shared/lists/components/sort_column_option.dart';

class FormListViewModel extends BaseViewModel with MessageStateMixin {
  final FormularyRepositoryImpl _formularyRepository;

  FormListViewModel(FormularyRepositoryImpl formularyRepository) : _formularyRepository = formularyRepository;

  final formularyList = <FormularyModel>[].obs;
  final filteredFormularyList = <FormularyModel>[].obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final filterMap = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    findAllFormulary({});
  }

  void filterFormulary(Map<String, dynamic> filters) {
    var tempList = formularyList.toList();

    if (filters.containsKey('search')) {
      final search = filters['search'].trim().toLowerCase() as String;
      tempList = tempList.where((form) => form.title.toLowerCase().contains(search)).toList();
    }

    if (filters.containsKey('status')) {
      final selectedStatuses = filters['status'].trim().toLowerCase().split(',').map((e) => e.trim()).toList();
      tempList = tempList.where((form) => selectedStatuses.contains(form.formStatus.name.toLowerCase())).toList();
    }

    filteredFormularyList.assignAll(tempList);
    update();
  }

  /// Atualiza o pageStatus baseado no tamanho da lista filtrada
  void updatePageStatusBasedOnList() {
    if (filteredFormularyList.isEmpty) {
      pageStatus.value = PageStatusEmpty(title: 'Nenhum formulário encontrado');
    } else {
      pageStatus.value = PageStatusSuccess<List<FormularyModel>>(filteredFormularyList);
    }
  }

  Future<Unit> findAllFormulary(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    await Future.delayed(const Duration(seconds: 2));
    final result = await _formularyRepository.findAllFormularies();
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (forms) {
        if (forms.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Nenhum formulário encontrado');
          return;
        }
        formularyList.assignAll(forms);
        filteredFormularyList.assignAll(forms);
        pageStatus.value = PageStatusSuccess<List<FormularyModel>>(forms);
      },
    );
    return Unit();
  }

  /// Ordena a lista filtrada baseado na opção de ordenação selecionada
  void sortByColumn(SortColumnOption sortOption) {
    final sortedList = List<FormularyModel>.from(filteredFormularyList);
    final isAscending = sortOption.direction == SortDirection.ascending;

    // Mapeia o título da coluna para o campo do modelo
    switch (sortOption.columnTitle) {
      case 'Name':
        sortedList.sort((a, b) {
          final comparison = a.title.compareTo(b.title);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'Description':
        sortedList.sort((a, b) {
          final comparison = a.description.compareTo(b.description);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'Status':
        sortedList.sort((a, b) {
          final comparison = a.formStatus.name.compareTo(b.formStatus.name);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'Questões':
        sortedList.sort((a, b) {
          final comparison = a.questionsCount.compareTo(b.questionsCount);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'Ultima Atualização':
        sortedList.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final comparison = aDate.compareTo(bDate);
          return isAscending ? comparison : -comparison;
        });
        break;
      default:
        // Se não encontrar correspondência, mantém a ordem original
        return;
    }

    filteredFormularyList.assignAll(sortedList);
    update();
  }

  Future<void> deleteFormulary(String id) async {
    final result = await _formularyRepository.deleteFormulary(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar formulário: ${exception.message}');
      },
      (unit) {
        showSuccess('formulário deletado com sucesso!');
        formularyList.removeWhere((profile) => profile.id == id);
        filteredFormularyList.removeWhere((profile) => profile.id == id);
        formularyList.refresh();
        filteredFormularyList.refresh();
        // Atualiza o pageStatus baseado no tamanho da lista após deletar
        updatePageStatusBasedOnList();
        update();
      },
    );
  }

  Future<void> changeFormularyStatus(FormularyModel formulary) async {
    final newStatus = formulary.formStatus == FormStatusEnum.inactive
        ? FormStatusEnum.active
        : formulary.formStatus == FormStatusEnum.active
        ? FormStatusEnum.inactive
        : formulary.formStatus == FormStatusEnum.editing
        ? FormStatusEnum.active
        : FormStatusEnum.inactive;

    final updatedFormulary = formulary.copyWith(formStatus: newStatus);

    final result = await _formularyRepository.saveFormulary(updatedFormulary);
    result.fold(
      (exception) {
        showError(exception.message);
      },
      (_) {
        final index = formularyList.indexWhere((a) => a.id == updatedFormulary.id);
        if (index != -1) {
          formularyList[index] = updatedFormulary;
          formularyList.refresh();
        }
        final filteredIndex = filteredFormularyList.indexWhere((a) => a.id == updatedFormulary.id);
        if (filteredIndex != -1) {
          filteredFormularyList[filteredIndex] = updatedFormulary;
          filteredFormularyList.refresh();
        }

        if (newStatus == FormStatusEnum.inactive) {
          showWarning('O formulário ${formulary.title} foi desativado');
        } else {
          showSuccess('O formulário ${formulary.title} foi ativado');
        }
      },
    );
  }
}
