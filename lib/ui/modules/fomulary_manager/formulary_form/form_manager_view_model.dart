import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/data/models/formulary/formulary_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/question_type_model.dart';
import 'package:versystems_app/data/models/formulary/questionnaire/section_model.dart';
import 'package:versystems_app/data/repositories/formulary/formulary_repository_impl.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_view_model.dart';
import 'package:versystems_app/config/controllers/app_state/app_state_controller.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';

class FormManagerViewModel extends GetxController with MessageStateMixin {
  final FormularyRepositoryImpl _formManagerRepository;

  FormManagerViewModel({required FormularyRepositoryImpl formManagerRepository})
    : _formManagerRepository = formManagerRepository;

  final FormListViewModel formListViewModel = Get.find<FormListViewModel>();
  final AppStateController appStateController = Get.find<AppStateController>();
  final AuthController authController = Get.find<AuthController>();
  final questionnaire = Rx<FormularyModel>(
    FormularyModel.empty(),
    // .copyWith(id: const Uuid().v4()),
  );

  final selectedSectionId = Rxn<String>();
  final selectedQuestionId = Rxn<String>();

  final Map<String, SyncedTextController> _questionControllers = {};
  final Map<String, SyncedTextController> _questionInstructionsControllers = {};
  final Map<String, SyncedTextController> _sectionControllers = {};

  final selectedQuestionOptionControllers = <TextEditingController>[].obs;

  TextEditingController getQuestionController(String id, String initialValue) {
    final synced = _questionControllers.putIfAbsent(id, () => SyncedTextController(initialValue));
    return synced.getController();
  }

  void releaseQuestionController(String id, TextEditingController controller) {
    final synced = _questionControllers[id];
    if (synced != null) {
      synced.removeController(controller);
    }
  }

  TextEditingController getQuestionInstructionsController(String id, String initialValue) {
    final synced = _questionInstructionsControllers.putIfAbsent(id, () => SyncedTextController(initialValue));
    return synced.getController();
  }

  void releaseQuestionInstructionsController(String id, TextEditingController controller) {
    final synced = _questionInstructionsControllers[id];
    if (synced != null) {
      synced.removeController(controller);
    }
  }

  TextEditingController getSectionController(String id, String initialValue) {
    final synced = _sectionControllers.putIfAbsent(id, () => SyncedTextController(initialValue));
    return synced.getController();
  }

  void releaseSectionController(String id, TextEditingController controller) {
    final synced = _sectionControllers[id];
    if (synced != null) {
      synced.removeController(controller);
    }
  }

  void clearControllersFor(String id) {
    _questionControllers.remove(id)?.dispose();
    _questionInstructionsControllers.remove(id)?.dispose();
    _sectionControllers.remove(id)?.dispose();
  }

  void selectSection(String sectionId) {
    selectedSectionId.value = sectionId;
    selectedQuestionId.value = null;
  }

  void selectQuestion(String sectionId, String questionId) {
    selectedSectionId.value = sectionId;
    selectedQuestionId.value = questionId;

    // Find the question and sync options
    final section = questionnaire.value.sections.firstWhereOrNull((s) => s.id == sectionId);
    final question = section?.questions.firstWhereOrNull((q) => q.id == questionId);
    syncOptionControllers(question?.questionOptions);
  }

  void clearSelection() {
    selectedSectionId.value = null;
    selectedQuestionId.value = null;
  }

  void syncOptionControllers(String? optionsString) {
    final controllersToDispose = List<TextEditingController>.from(selectedQuestionOptionControllers);
    selectedQuestionOptionControllers.clear();
    if (optionsString != null && optionsString.isNotEmpty) {
      final options = optionsString.split(RegExp(r';\n|[\n;]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      for (final opt in options) {
        selectedQuestionOptionControllers.add(TextEditingController(text: opt));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in controllersToDispose) {
        c.dispose();
      }
    });
  }

  void updateQuestionOptionsFromControllers(String sectionId, String questionId) {
    final newOptions = selectedQuestionOptionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join('\n');
    updateQuestionUi(
      sectionId: sectionId,
      questionId: questionId,
      update: (current) => current.copyWith(questionOptions: newOptions),
    );
    appStateController.formHasUnsavedValues.value = true;
  }

  void addOptionToSelectedQuestion() {
    final sId = selectedSectionId.value;
    final qId = selectedQuestionId.value;
    if (sId == null || qId == null) return;
    selectedQuestionOptionControllers.add(TextEditingController(text: 'Nova Opção'));
    updateQuestionOptionsFromControllers(sId, qId);
  }

  void removeOptionFromSelectedQuestion(int index) {
    final sId = selectedSectionId.value;
    final qId = selectedQuestionId.value;
    if (sId == null || qId == null) return;
    if (index >= 0 && index < selectedQuestionOptionControllers.length) {
      final controller = selectedQuestionOptionControllers.removeAt(index);
      updateQuestionOptionsFromControllers(sId, qId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.dispose();
      });
    }
  }

  int getSelectedSectionIndex() {
    final sId = selectedSectionId.value;
    if (sId == null) return -1;
    return questionnaire.value.sections.indexWhere((s) => s.id == sId);
  }

  int getSelectedQuestionIndex(int sIndex) {
    final qId = selectedQuestionId.value;
    if (qId == null || sIndex == -1) return -1;
    return questionnaire.value.sections[sIndex].questions.indexWhere((q) => q.id == qId);
  }

  final formularyTitleEC = TextEditingController();
  final formularyDescriptionEC = TextEditingController();
  final selectedQuestionType = Rx<QuestionType>(TypeSimpleText());
  final questionTypeList = <QuestionType>[
    TypeSimpleText(),
    TypeNumber(),
    TypeTelephone(),
    TypeCellphone(),
    TypeCnpj(),
    TypeCpf(),
    TypeRg(),
    TypeHiddenText(),
    TypeListBoxSingleSelect(),
    TypeListBoxMultiSelect(),
    TypeRadioButton(),
    TypeCheckbox(),
    TypeImagePicker(),
    TypeDateInput(),
    TypeSignature(),
    TypeGpsLocation(),
  ];
  final questionTypeOptionEnable = <QuestionType>[
    TypeListBoxSingleSelect(),
    TypeListBoxMultiSelect(),
    TypeRadioButton(),
    TypeCheckbox(),
  ];
  final sectionTileExpanded = true.obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final saveFormStatus = Rx<PageStatus>(PageStatusIdle());
  final formularyList = RxList<FormularyModel>([]);

  /// ------------------------------------------------------
  // // UI-only: lista estável de SortableData por seção (chave = sectionId)
  final RxMap<String, RxList<SortableData<QuestionModel>>> uiQuestionsBySectionId =
      <String, RxList<SortableData<QuestionModel>>>{}.obs;

  // cache (opcional) pra reutilizar o MESMO SortableData por questionId
  final Map<String, SortableData<QuestionModel>> _sdCacheByQuestionId = {};
  SortableData<QuestionModel> _sdForQuestion(QuestionModel q) {
    final id = q.id;
    return _sdCacheByQuestionId.putIfAbsent(id, () => SortableData(q));
  }

  RxList<SortableData<QuestionModel>> uiListForSection(SectionModel section) {
    return uiQuestionsBySectionId.putIfAbsent(section.id, () => <SortableData<QuestionModel>>[].obs);
  }

  void _rebuildUiQuestionsFromModel() {
    uiQuestionsBySectionId.clear();
    _sdCacheByQuestionId.clear();

    for (final section in questionnaire.value.sections) {
      final uiList = uiListForSection(section);
      uiList.assignAll(section.questions.map(_sdForQuestion));
    }
  }

  void _applyUiOrderToModel() {
    questionnaire.update((val) {
      if (val == null) return;

      for (final section in val.sections) {
        final uiList = uiQuestionsBySectionId[section.id];
        if (uiList == null) continue;

        section.questions = uiList.map((sd) => sd.data).toList();
      }
    });
  }

  void updateQuestionUi({
    required String sectionId,
    required String questionId,
    required QuestionModel Function(QuestionModel current) update,
  }) {
    final uiList = uiQuestionsBySectionId[sectionId];
    if (uiList == null) return;

    final idx = uiList.indexWhere((sd) => sd.data.id == questionId);
    if (idx == -1) return;

    final current = uiList[idx].data;
    final next = update(current);

    if (questionId == selectedQuestionId.value) {
      final currentControllersString = selectedQuestionOptionControllers.map((c) => c.text.trim()).join('\n');
      if (next.questionOptions != current.questionOptions && next.questionOptions != currentControllersString) {
        syncOptionControllers(next.questionOptions);
      }
    }

    // mantém o MESMO SortableData? -> não dá, SortableData é imutável
    // então a gente substitui o item na UI list por um novo SortableData
    // e atualiza cache para manter estabilidade nas próximas reconstruções.
    final newSd = SortableData(next);
    uiList[idx] = newSd;

    // garante que o modelo final (questionnaire) fique em dia
    _sdCacheByQuestionId[questionId] = newSd;
    _applyUiOrderToModel();

    // às vezes ajuda o GetX em árvores grandes
    // uiList.refresh();
  }

  /// ------------------------------------------------------

  void moveQuestion(int sIndex, int fromIndex, int toIndex) {
    final questions = List<QuestionModel>.from(questionnaire.value.sections[sIndex].questions);

    // clamp básico
    if (fromIndex < 0 || fromIndex >= questions.length) return;
    if (toIndex < 0) toIndex = 0;
    if (toIndex > questions.length) toIndex = questions.length;

    final item = questions.removeAt(fromIndex);

    // quando você remove, os índices depois “puxam” 1 pra cima
    if (toIndex > fromIndex) toIndex -= 1;

    questions.insert(toIndex, item);

    questionnaire.update((val) {
      val?.sections[sIndex].questions = questions;
    });
  }

  void moveQuestionById(int sIndex, String questionId, int toIndex) {
    final questions = List<QuestionModel>.from(questionnaire.value.sections[sIndex].questions);
    final fromIndex = questions.indexWhere((q) => q.id == questionId);
    if (fromIndex == -1) return;

    if (toIndex < 0) toIndex = 0;
    if (toIndex > questions.length) toIndex = questions.length;

    final item = questions.removeAt(fromIndex);
    if (toIndex > fromIndex) toIndex -= 1;
    questions.insert(toIndex, item);

    questionnaire.update((val) {
      val?.sections[sIndex].questions = questions;
    });
  }

  void removeQuestionById(int sIndex, String questionId) {
    final section = questionnaire.value.sections[sIndex];

    if (selectedQuestionId.value == questionId) {
      clearSelection();
    }
    clearControllersFor(questionId);

    // model
    final updated = List<QuestionModel>.from(section.questions)..removeWhere((q) => q.id == questionId);

    questionnaire.update((val) {
      val?.sections[sIndex].questions = updated;
    });

    // ui
    final uiList = uiQuestionsBySectionId[section.id];
    uiList?.removeWhere((sd) => sd.data.id == questionId);

    _applyUiOrderToModel();
  }

  void moveQuestionUiByIndex(int sIndex, int fromIndex, int toIndex) {
    final section = questionnaire.value.sections[sIndex];
    final uiList = uiQuestionsBySectionId[section.id];
    if (uiList == null) return;

    if (fromIndex < 0 || fromIndex >= uiList.length) return;
    if (toIndex < 0) toIndex = 0;
    if (toIndex > uiList.length) toIndex = uiList.length;

    final item = uiList.removeAt(fromIndex);
    if (toIndex > fromIndex) toIndex -= 1;
    uiList.insert(toIndex, item);

    _applyUiOrderToModel(); // mantém payload em dia
  }

  void moveQuestionUiById(int sIndex, String questionId, int toIndex) {
    final section = questionnaire.value.sections[sIndex];
    final uiList = uiQuestionsBySectionId[section.id];
    if (uiList == null) return;

    final fromIndex = uiList.indexWhere((sd) => sd.data.id == questionId);
    if (fromIndex == -1) return;

    if (toIndex < 0) toIndex = 0;
    if (toIndex > uiList.length) toIndex = uiList.length;

    final item = uiList.removeAt(fromIndex);
    if (toIndex > fromIndex) toIndex -= 1;
    uiList.insert(toIndex, item);

    _applyUiOrderToModel();
  }

  void initialize(String id) async {
    pageStatus.value = PageStatusLoading();
    await Future.delayed(const Duration(seconds: 1));
    if (formListViewModel.formularyList.isEmpty) {
      await formListViewModel.findAllFormulary({});
    }
    formularyList.assignAll(formListViewModel.formularyList);
    if (id != 'new') {
      final matchingForm = formListViewModel.formularyList.firstWhereOrNull((element) => element.id == id);

      if (matchingForm != null) {
        questionnaire.value = matchingForm.copyWith();
        _rebuildUiQuestionsFromModel();
        formularyTitleEC.text = matchingForm.title;
        formularyDescriptionEC.text = matchingForm.description;
        pageStatus.value = PageStatusSuccess<Rx<FormularyModel>>(questionnaire);
      } else {
        pageStatus.value = PageStatusError('Formulário não encontrado com id $id');
        // Aqui você pode mostrar um erro ou redirecionar
        debugPrint('Formulário não encontrado com id $id');
        // formManagerViewModel.isScreenLoading(false); // já está no finally
        return;
      }
    } else {
      _rebuildUiQuestionsFromModel();
      pageStatus.value = PageStatusSuccess<Rx<FormularyModel>>(questionnaire);
    }
  }

  void setNewFormulary(FormularyModel formulary) {
    formularyTitleEC.text = formulary.title;
    formularyDescriptionEC.text = formulary.description;
    questionnaire.value = formulary;
    _rebuildUiQuestionsFromModel();
    update();
  }

  Future<Unit> onSaveFormulary() async {
    saveFormStatus.value = PageStatusLoading();
    pageStatus.value = PageStatusLoading();
    _applyUiOrderToModel();

    final currentUser = authController.localUserModel.value;
    final formularyModel = questionnaire.value.copyWith(
      createdAt: questionnaire.value.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: currentUser,
    );

    await Future.delayed(const Duration(seconds: 1));
    final result = await _formManagerRepository.saveFormulary(formularyModel);
    result.fold(
      (RepositoryException re) {
        saveFormStatus.value = PageStatusError(re.message);
        showError(re.message);
      },
      (String formularyId) {
        if (questionnaire.value.id != '') {
          final index = formListViewModel.formularyList.indexWhere((form) => form.id == questionnaire.value.id);
          if (index != -1) {
            final updatedFormulary = formularyModel.copyWith(id: questionnaire.value.id);
            formListViewModel.formularyList[index] = updatedFormulary;
            // Atualiza também na lista filtrada se o item estiver lá
            final filteredIndex = formListViewModel.filteredFormularyList.indexWhere(
              (form) => form.id == questionnaire.value.id,
            );
            if (filteredIndex != -1) {
              formListViewModel.filteredFormularyList[filteredIndex] = updatedFormulary;
            }
          }
          formListViewModel.formularyList.refresh();
          formListViewModel.filteredFormularyList.refresh();
        } else {
          // Verifica se a lista estava vazia antes de adicionar
          final wasEmpty = formListViewModel.filteredFormularyList.isEmpty;
          final newFormulary = formularyModel.copyWith(id: formularyId);
          formListViewModel.formularyList.insert(0, newFormulary);
          formListViewModel.filteredFormularyList.insert(0, newFormulary);
          formListViewModel.formularyList.refresh();
          formListViewModel.filteredFormularyList.refresh();
          // Se estava vazia, atualiza o pageStatus para Success
          if (wasEmpty) {
            formListViewModel.updatePageStatusBasedOnList();
          }
        }
        showSuccess('Formulário salvo com sucesso');
        appStateController.formHasUnsavedValues.value = false;
        saveFormStatus.value = PageStatusSuccess<String>('Formulário salvo com sucesso');
        pageStatus.value = PageStatusSuccess<Rx<FormularyModel>>(questionnaire);
      },
    );

    return Unit();
  }

  void addQuestion(int sIndex) {
    final section = questionnaire.value.sections[sIndex];
    // final updatedQuestion = List<QuestionModel>.from(questionnaire.value.sections[sIndex].questions);
    // ..add(
    //   QuestionModel(
    //     id: const Uuid().v4(),
    //     question: "Nova pergunta",
    //     questionType: "simpleTextInput",
    //     questionRequired: false,
    //     questionOptions: "",
    //     questionInstructions: "",
    //   ),
    // );
    final newQ = QuestionModel(
      id: const Uuid().v4(),
      question: "Nova pergunta",
      questionType: "simpleTextInput",
      questionRequired: false,
      questionOptions: "",
      questionInstructions: "",
    );
    // questionnaire.update((val) {
    //   val?.sections[sIndex].questions = updatedQuestion;
    // });
    // 1) model
    final updated = List<QuestionModel>.from(section.questions)..add(newQ);
    questionnaire.update((val) {
      val?.sections[sIndex].questions = updated;
    });

    // 2) ui
    final uiList = uiListForSection(section);
    uiList.add(_sdForQuestion(newQ));

    // (opcional) garante ordem model
    _applyUiOrderToModel();
    // questionEditModeList[sIndex].add(true.obs);
  }

  Future<void> addSection([int? afterIndex]) async {
    final newSection = SectionModel(id: const Uuid().v4(), sectionTitle: "Nova Sessão", questions: []);
    final updatedSections = List<SectionModel>.from(questionnaire.value.sections);
    int targetIndex = updatedSections.length;
    if (afterIndex != null && afterIndex >= 0 && afterIndex < updatedSections.length) {
      targetIndex = afterIndex + 1;
      updatedSections.insert(targetIndex, newSection);
    } else {
      updatedSections.add(newSection);
    }

    questionnaire.update((val) {
      val?.sections = updatedSections;
    });

    if (questionnaire.value.sections.isNotEmpty) {
      addQuestion(targetIndex);
    }
    _rebuildUiQuestionsFromModel();
  }

  void duplicateQuestion(int sIndex, int qIndex) {
    // final questions = List<QuestionModel>.from(questionnaire.value.sections[sIndex].questions);
    // final duplicatedQuestions = QuestionModel(
    //   id: const Uuid().v4(),
    //   question: '${questions[qIndex].question} (cópia)',
    //   questionType: questions[qIndex].questionType,
    //   questionRequired: questions[qIndex].questionRequired,
    //   questionOptions: questions[qIndex].questionOptions,
    //   questionInstructions: questions[qIndex].questionInstructions,
    // );

    // questions.insert(qIndex + 1, duplicatedQuestions);
    // questionnaire.update((val) {
    //   val?.sections[sIndex].questions = questions;
    // });
    final section = questionnaire.value.sections[sIndex];
    if (qIndex < 0 || qIndex >= section.questions.length) return;

    final original = section.questions[qIndex];

    final copy = QuestionModel(
      id: const Uuid().v4(),
      question: '${original.question} (cópia)',
      questionType: original.questionType,
      questionRequired: original.questionRequired,
      questionOptions: original.questionOptions,
      questionInstructions: original.questionInstructions,
    );

    // model
    final updated = List<QuestionModel>.from(section.questions)..insert(qIndex + 1, copy);

    questionnaire.update((val) {
      val?.sections[sIndex].questions = updated;
    });

    // ui
    final uiList = uiListForSection(section);
    uiList.insert(qIndex + 1, _sdForQuestion(copy));

    _applyUiOrderToModel();
  }

  void duplicateSection(int sIndex) {
    if (sIndex >= 0 && sIndex < questionnaire.value.sections.length) {
      final sections = List<SectionModel>.from(questionnaire.value.sections);

      final original = sections[sIndex];
      final clonedQuestions = original.questions.map((q) => q.copyWith(id: const Uuid().v4())).toList();

      final duplicatedSection = SectionModel(
        id: const Uuid().v4(),
        sectionTitle: '${original.sectionTitle} (cópia)',
        questions: clonedQuestions,
      );

      sections.insert(sIndex + 1, duplicatedSection);

      questionnaire.update((val) {
        val?.sections = sections;
      });
    }
    _rebuildUiQuestionsFromModel();
  }

  void removeQuestion(int sIndex, int qIndex) {
    if (questionnaire.value.sections[sIndex].questions.length > 1) {
      final section = questionnaire.value.sections[sIndex];

      // 1) model: remove
      if (qIndex < 0 || qIndex >= section.questions.length) return;
      final removed = section.questions[qIndex];

      if (selectedQuestionId.value == removed.id) {
        clearSelection();
      }
      clearControllersFor(removed.id);

      final updated = List<QuestionModel>.from(section.questions)..removeAt(qIndex);
      questionnaire.update((val) {
        val?.sections[sIndex].questions = updated;
      });

      // 2) ui: remove pelo id
      final uiList = uiQuestionsBySectionId[section.id];
      uiList?.removeWhere((sd) => sd.data.id == removed.id);

      _applyUiOrderToModel();
    } else {
      showError('Não é possível remover a última pergunta');
    }
  }

  void removeSection(int sIndex) {
    if (questionnaire.value.sections.length > 1) {
      if (sIndex >= 0 && sIndex < questionnaire.value.sections.length) {
        final removedSection = questionnaire.value.sections[sIndex];
        if (selectedSectionId.value == removedSection.id) {
          clearSelection();
        }
        for (final q in removedSection.questions) {
          clearControllersFor(q.id);
        }
        clearControllersFor(removedSection.id);

        final updatedSections = List<SectionModel>.from(questionnaire.value.sections)..removeAt(sIndex);
        questionnaire.update((val) {
          val?.sections = updatedSections;
        });
        _rebuildUiQuestionsFromModel();
      }
    } else {
      showError('Não é possível remover a última seção');
    }
  }

  void showMessage(String message, MessageType type) {
    switch (type) {
      case MessageType.success:
        showSuccess(message);
        break;
      case MessageType.error:
        showError(message);
        break;
      case MessageType.warning:
        showWarning(message);
        break;
      case MessageType.info:
        showInfo(message);
        break;
    }
  }

  @override
  void onClose() {
    for (final synced in _questionControllers.values) {
      synced.dispose();
    }
    for (final synced in _questionInstructionsControllers.values) {
      synced.dispose();
    }
    for (final synced in _sectionControllers.values) {
      synced.dispose();
    }
    for (final controller in selectedQuestionOptionControllers) {
      controller.dispose();
    }
    formularyTitleEC.dispose();
    formularyDescriptionEC.dispose();
    super.onClose();
  }
}

class SyncedTextController {
  String _value;
  final Set<TextEditingController> _controllers = {};
  bool _isUpdating = false;

  SyncedTextController(this._value);

  TextEditingController getController() {
    final controller = TextEditingController(text: _value);
    _controllers.add(controller);

    controller.addListener(() {
      if (_isUpdating) return;
      if (controller.text != _value) {
        _value = controller.text;
        _isUpdating = true;
        try {
          for (final c in _controllers) {
            if (c != controller && c.text != _value) {
              c.text = _value;
            }
          }
        } finally {
          _isUpdating = false;
        }
      }
    });

    return controller;
  }

  void removeController(TextEditingController controller) {
    _controllers.remove(controller);
    controller.dispose();
  }

  void updateValue(String newValue) {
    if (_value != newValue) {
      _value = newValue;
      _isUpdating = true;
      try {
        for (final c in _controllers) {
          if (c.text != _value) {
            c.text = _value;
          }
        }
      } finally {
        _isUpdating = false;
      }
    }
  }

  void dispose() {
    _isUpdating = true;
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
  }
}
