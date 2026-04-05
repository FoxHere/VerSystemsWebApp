import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';

class ProfileListViewModel extends BaseViewModel with MessageStateMixin {
  final ProfileRepositoryImpl _profileRepository;

  ProfileListViewModel({required ProfileRepositoryImpl profileRepository}) : _profileRepository = profileRepository;

  final profileList = <ProfileModel>[].obs;
  final pageStatus = Rx<PageStatus>(PageStatusIdle());

  @override
  void onInit() {
    super.onInit();
    findAllProfiles({});
  }

  Future<void> findAllProfiles(Map<String, dynamic> filters) async {
    pageStatus.value = PageStatusLoading();
    await Future.delayed(const Duration(seconds: 1));
    final result = await _profileRepository.findAllProfiles(filters);
    result.fold(
      (exception) {
        pageStatus.value = PageStatusError(exception.message);
        showError(exception.message);
      },
      (List<ProfileModel> profiles) {
        if (profiles.isEmpty) {
          pageStatus.value = PageStatusEmpty(title: 'Não existem departamentos cadastrados');
          return;
        }
        profileList.assignAll(profiles);
        pageStatus.value = PageStatusSuccess<List<ProfileModel>>(profileList);
      },
    );
  }

  Future<void> deleteProfile(String id) async {
    final result = await _profileRepository.deleteProfile(id);
    result.fold(
      (exception) {
        showError('Erro ao deletar departamento: ${exception.message}');
      },
      (unit) {
        showSuccess('Departamento deletado com sucesso!');
        profileList.removeWhere((profile) => profile.id == id);
        profileList.refresh();
        update();
      },
    );
  }
}
