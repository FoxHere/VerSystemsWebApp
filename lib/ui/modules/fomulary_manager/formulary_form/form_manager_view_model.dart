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

  FormManagerViewModel({required FormularyRepositoryImpl formManagerRepository}) : _formManagerRepository = formManagerRepository;

  final FormListViewModel formListViewModel = Get.find<FormListViewModel>();
  final AppStateController appStateController = Get.find<AppStateController>();
  final AuthController authController = Get.find<AuthController>();
  final questionnaire = Rx<FormularyModel>(
    FormularyModel.empty(),
    // .copyWith(id: const Uuid().v4()),
  );

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
  ];
  final questionTypeOptionEnable = <QuestionType>[TypeListBoxSingleSelect(), TypeListBoxMultiSelect(), TypeRadioButton(), TypeCheckbox()];
  final sectionTileExpanded = true.obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final saveFormStatus = Rx<PageStatus>(PageStatusIdle());
  final formularyList = RxList<FormularyModel>([]);

  /// ------------------------------------------------------
  // // UI-only: lista estável de SortableData por seção (chave = sectionId)
  final RxMap<String, RxList<SortableData<QuestionModel>>> uiQuestionsBySectionId = <String, RxList<SortableData<QuestionModel>>>{}.obs;

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

  void updateQuestionUi({required String sectionId, required String questionId, required QuestionModel Function(QuestionModel current) update}) {
    final uiList = uiQuestionsBySectionId[sectionId];
    if (uiList == null) return;

    final idx = uiList.indexWhere((sd) => sd.data.id == questionId);
    if (idx == -1) return;

    final current = uiList[idx].data;
    final next = update(current);

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
            final filteredIndex = formListViewModel.filteredFormularyList.indexWhere((form) => form.id == questionnaire.value.id);
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

  Future<void> addSection() async {
    final updatedSections = List<SectionModel>.from(questionnaire.value.sections)
      ..add(SectionModel(id: const Uuid().v4(), sectionTitle: "Nova Sessão", questions: []));
    questionnaire.update((val) {
      val?.sections = updatedSections;
    });

    if (questionnaire.value.sections.isNotEmpty) {
      final lastIndex = questionnaire.value.sections.length - 1;
      addQuestion(lastIndex);
    }
    _rebuildUiQuestionsFromModel();
    // questionEditModeList.add(<RxBool>[]);
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

      final duplicatedSection = SectionModel(
        id: const Uuid().v4(),
        sectionTitle: '${sections[sIndex].sectionTitle} (cópia)',
        questions: sections[sIndex].questions,
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
      // if (qIndex >= 0 && qIndex < questionnaire.value.sections[sIndex].questions.length) {
      //   final updatedQuestions = List<QuestionModel>.from(questionnaire.value.sections[sIndex].questions)..removeAt(qIndex);
      //   questionnaire.update((val) {
      //     val?.sections[sIndex].questions = updatedQuestions;
      //   });
      // }
      final section = questionnaire.value.sections[sIndex];

      // 1) model: remove
      if (qIndex < 0 || qIndex >= section.questions.length) return;
      final removed = section.questions[qIndex];

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
}
