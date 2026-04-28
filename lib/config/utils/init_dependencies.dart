import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:versystems_app/config/controllers/app_session/app_session_controller.dart';
import 'package:versystems_app/config/controllers/app_state/app_state_controller.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/controllers/responsiveness/responsive_controller.dart';
import 'package:versystems_app/config/controllers/theme/theme_controller.dart';
import 'package:versystems_app/config/utils/firebase_options.dart';
import 'package:versystems_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:versystems_app/data/repositories/company/company_repository_impl.dart';
import 'package:versystems_app/data/repositories/user/user_repository_impl.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/data/services/auth/auth_services_impl.dart';
import 'package:versystems_app/data/services/company/company_services.dart';
import 'package:versystems_app/data/services/dashboard/dashboard_functions_service.dart';
import 'package:versystems_app/data/services/department/department_services_impl.dart';
import 'package:versystems_app/data/services/dev/dev_services.dart';
import 'package:versystems_app/data/services/firebase_functions/firebase_functions_service_impl.dart';
import 'package:versystems_app/data/services/image/image_services.dart';
import 'package:versystems_app/data/services/profile/profile_services_impl.dart';
import 'package:versystems_app/data/services/user/user_services_impl.dart';

Future<void> initDependencies() async {
  // -----------------------------------------------Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // String host = '127.0.0.1';
  //if (!kIsWeb && Platform.isAndroid) host = '10.0.2.2'; // Android emulator
  // Verificar se o app está dem debug mode para usar o firebase local emulator
  // if (kDebugMode) {
  //   try {
  //     debugPrint('Initializing Firebase emulators...');
  //     await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  //     await FirebaseStorage.instance.useStorageEmulator(host, 9199);
  //     FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  //     FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  Get.put(ThemeController(), permanent: true);
  // Initial bindings
  Get.put(AppSessionController(), permanent: true);
  Get.put(AppStateController(), permanent: true);
  Get.put(ResponsiveController(), permanent: true);
  Get.put(AuthServiceImpl());
  Get.put(UserServicesImpl());
  Get.put(DepartmentServicesImpl());
  Get.put(ProfileServicesImpl());
  Get.put(ActivityServices(), permanent: true);
  Get.put(ImageServices(), permanent: true);
  Get.put(DevServices(), permanent: true);
  Get.put(CompanyServices(), permanent: true);
  Get.put(CompanyRepositoryImpl(companyServices: Get.find<CompanyServices>()), permanent: true);
  Get.put(FirebaseFunctionsServiceImpl(), permanent: true);
  Get.put(
    AuthRepositoryImpl(
      authServiceImp: Get.find<AuthServiceImpl>(),
      userServicesImpl: Get.find<UserServicesImpl>(),
      departmentServicesImpl: Get.find<DepartmentServicesImpl>(),
      profileServivesImpl: Get.find<ProfileServicesImpl>(),
    ),
  );
  Get.put(DashboardFunctionsServiceImpl(firebaseFunctionsService: Get.find<FirebaseFunctionsServiceImpl>()));
  Get.put(
    UserRepositoryImpl(
      dashboardFunctionsService: Get.find<DashboardFunctionsServiceImpl>(),
      userServicesImpl: Get.find<UserServicesImpl>(),
      profileServicesImpl: Get.find<ProfileServicesImpl>(),
      departmentServicesImpl: Get.find<DepartmentServicesImpl>(),
      imageServices: Get.find<ImageServices>(),
      firebaseFunctionsServicesImpl: Get.find<FirebaseFunctionsServiceImpl>(),
    ),
  );
  Get.lazyPut(
    () => AuthController(
      userRepositoryImpl: Get.find<UserRepositoryImpl>(),
      authRepositoryImpl: Get.find<AuthRepositoryImpl>(),
    ),
    fenix: true,
  );

  // -----------------------------------------------Dev Services initialization
  // final devServices = Get.find<DevServices>();
  // final result = await devServices.createMenuItemsOnfirebase();
  // result.fold(
  //   (l) => debugPrint('Error creating menu items: ${l.message}'),
  //   (r) => debugPrint(r.toString()),
  // );
  // ---------------------------------------------------------------------------
}
