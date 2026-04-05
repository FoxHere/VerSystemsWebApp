import 'package:get/get.dart';
import 'package:versystems_app/config/utils/auto_dispose_bindings.dart';
import 'package:versystems_app/data/repositories/profile/profile_repository_impl.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_form/profile_form_view_model.dart';

class ProfileFormBindings extends AutoDisposeBindings {
  @override
  void dependencies() {
    autoPut(ProfileServicesImpl());
    autoPut(UserServicesImpl());
    autoLazyPut(
      ProfileRepositoryImpl(
        profileServices: Get.find<ProfileServicesImpl>(),
        userServices: Get.find<UserServicesImpl>(),
      ),
    );
    autoLazyPut(
      ProfileFormViewModel(
        profileRepository: Get.find<ProfileRepositoryImpl>(),
      ),
    );
  }
}
