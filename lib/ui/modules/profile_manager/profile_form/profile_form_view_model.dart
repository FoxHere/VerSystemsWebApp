import 'package:get/get.dart';
import 'package:versystems_app/config/helpers/messages/messages.dart';
import 'package:versystems_app/config/utils/app_page_status.dart';
import 'package:versystems_app/config/utils/base_view_model.dart';
import 'package:versystems_app/data/models/profile/profile_model.dart';
import 'package:versystems_app/data/models/profile/profile_status.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/profile_list_view_model.dart';

class ProfileFormViewModel extends BaseViewModel with MessageStateMixin {
  final ProfileRepositoryImpl _profileRepository;

  ProfileFormViewModel({required ProfileRepositoryImpl profileRepository}) : _profileRepository = profileRepository;

  final profileListViewModel = Get.find<ProfileListViewModel>(tag: 'depList');
  final pageStatus = Rx<PageStatus>(PageStatusIdle());
  final profileModel = Rx<ProfileModel>(
    ProfileModel(
      id: '',
      name: '',
      profileStatus: ProfileStatusEnum.active,
      description: '',
      level: 0,
      allowedMenus: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  Future<void> initialize(String profileId) async {
    pageStatus.value = PageStatusLoading();

    await Future.delayed(const Duration(seconds: 1));
    if (profileId != 'new') {
      if (profileListViewModel.profileList.isEmpty) {
        await profileListViewModel.findAllProfiles({});
      }
      final matchingProfile = profileListViewModel.profileList.firstWhereOrNull((activity) => activity.id == profileId);
      if (matchingProfile != null) {
        pageStatus.value = PageStatusSuccess<ProfileModel>(matchingProfile);
      } else {
        showError('Pefil não encontrado');
        pageStatus.value = PageStatusError('Pefil não encontrado');
      }
      return;
    } else {
      pageStatus.value = PageStatusSuccess<ProfileModel?>(
        ProfileModel(
          id: '',
          name: '',
          profileStatus: ProfileStatusEnum.active,
          description: '',
          level: 0,
          allowedMenus: [],
          createdAt: DateTime.now(),
          updatedAt: null,
        ),
      );
      return;
    }
  }

  Future<void> saveProfile(ProfileModel model) async {
    try {
      pageStatus.value = PageStatusLoading();
      final profile = model.copyWith(createdAt: model.createdAt ?? DateTime.now(), updatedAt: DateTime.now());

      final result = await _profileRepository.saveProfile(profile);
      result.fold(
        (exception) {
          showError('Erro ao salvar perfil: ${exception.message}');
        },
        (profileId) {
          if (model.id != '') {
            final index = profileListViewModel.profileList.indexWhere((dep) => dep.id == model.id);
            if (index != -1) profileListViewModel.profileList[index] = profile;
            profileListViewModel.profileList.refresh();
          } else {
            profileListViewModel.profileList.insert(0, profile.copyWith(id: profileId));
          }
          showSuccess('Operação realizada com sucesso!');
          pageStatus.value = PageStatusSuccess<ProfileModel>(profileModel.value);
        },
      );
    } catch (e) {
      showError('Erro ao salvar perfil: $e');
    }
    pageStatus.value = PageStatusSuccess<ProfileModel>(model);
  }
}
