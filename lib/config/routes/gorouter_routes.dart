import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:versystems_app/config/controllers/app_state/app_state_controller.dart';
import 'package:versystems_app/config/controllers/auth/auth_controller.dart';
import 'package:versystems_app/config/guards/auth_guard_impl.dart';
import 'package:versystems_app/config/guards/menu_access_guard_impl.dart';
import 'package:versystems_app/config/guards/route_guard.dart';
import 'package:versystems_app/config/helpers/routes/paths_helper.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';
import 'package:versystems_app/config/utils/get_bindings_wrapper.dart';
import 'package:versystems_app/data/services/activity/activity_services.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_form/activity_manager_bindings.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_form/activity_manager_view.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_bindings.dart';
import 'package:versystems_app/ui/modules/activity_manager/activity_list/activity_list_view.dart';
import 'package:versystems_app/ui/modules/client_manager/client_form/client_manager_bindings.dart';
import 'package:versystems_app/ui/modules/client_manager/client_form/client_manager_view.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_bindings.dart';
import 'package:versystems_app/ui/modules/client_manager/client_list/client_list_view.dart';
import 'package:versystems_app/ui/modules/company_manager/company_form/company_manager_bindings.dart';
import 'package:versystems_app/ui/modules/company_manager/company_form/company_manager_view.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/company_list_bindings.dart';
import 'package:versystems_app/ui/modules/company_manager/company_list/company_list_view.dart';
import 'package:versystems_app/ui/modules/dashboard/dashboard_bindigns.dart';

import 'package:versystems_app/ui/modules/dashboard/dashboard_view.dart';
import 'package:versystems_app/ui/modules/department_manager/department_form/department_form_bindings.dart';
import 'package:versystems_app/ui/modules/department_manager/department_form/department_form_view.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/department_list_bindings.dart';
import 'package:versystems_app/ui/modules/department_manager/department_list/department_list_view.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_bindings.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_form/form_manager_view.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_bindings.dart';
import 'package:versystems_app/ui/modules/fomulary_manager/formulary_list/form_list_view.dart';
import 'package:versystems_app/ui/modules/home/home_bindings.dart';
import 'package:versystems_app/ui/modules/home/home_view.dart';

import 'package:versystems_app/ui/modules/login/login_bindigns.dart';
import 'package:versystems_app/ui/modules/login/login_view.dart';
import 'package:versystems_app/ui/modules/not_found_page/not_found_page.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_form/profile_form_bindings.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_form/profile_form_view.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/profile_list_bindings.dart';
import 'package:versystems_app/ui/modules/profile_manager/profile_list/profile_list_view.dart';
import 'package:versystems_app/ui/modules/settings/settings_bindings.dart';
import 'package:versystems_app/ui/modules/settings/settings_view.dart';
import 'package:versystems_app/ui/modules/splash/splash_view.dart';
import 'package:versystems_app/ui/modules/setup/setup_bindings.dart';
import 'package:versystems_app/ui/modules/setup/setup_view.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/task_manager_bindings.dart';
import 'package:versystems_app/ui/modules/task_manager/task_form/task_manager_view.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_bindings.dart';
import 'package:versystems_app/ui/modules/task_manager/task_list/task_list_view.dart';
import 'package:versystems_app/ui/modules/user_manager/user_form/user_form_bindings.dart';
import 'package:versystems_app/ui/modules/user_manager/user_form/user_form_view.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_bindings.dart';
import 'package:versystems_app/ui/modules/user_manager/user_list/user_list_view.dart';
import 'package:versystems_app/ui/modules/user_profile/user_profile_bindings.dart';
import 'package:versystems_app/ui/modules/user_profile/user_profile_view.dart';

import 'package:versystems_app/ui/modules/company_switcher/company_switcher_bindings.dart';
import 'package:versystems_app/ui/modules/company_switcher/company_switcher_view.dart';

final AuthController authController = Get.find<AuthController>();
final AppStateController appstateController = Get.find<AppStateController>();
final ActivityServices activityServices = Get.find<ActivityServices>();

final GoRouter router = GoRouter(
  initialLocation: RoutesHelper.splash,
  debugLogDiagnostics: true,
  redirectLimit: 3,
  observers: [],
  refreshListenable: GoRouterAuthListener(),
  redirect: (context, state) async {
    // se a rota não for splash
    if (state.fullPath != RoutesHelper.splash) {
      // verifica se já foi inicializada
      final isInitialized = Get.isRegistered<bool>(tag: 'splashInitialized');
      if (!isInitialized) {
        // se não foi então redireciona para a splash
        return '${RoutesHelper.splash}?redirectTo=${state.matchedLocation}';
      }
    }
    // se não passa para a rota desejada
    return null;
  },
  routes: [
    GoRoute(
      name: 'splash',
      path: RoutesHelper.splash,
      builder: (context, state) {
        return SplashView(redirectTo: state.uri.queryParameters['redirectTo']);
      },
      redirect: (context, state) {
        final isInitialized = Get.isRegistered<bool>(tag: 'splashInitialized');
        if (isInitialized) {
          // Aqui vamos direcionar ele para uma rota interna se não tiver logado a rota vai direcionar para o login
          return RoutesHelper.login;
        }
        return null;
      },
    ),
    GoRoute(
      name: 'login',
      path: RoutesHelper.login,
      builder: (context, state) {
        return GetBindingsWrapper(
          binding: LoginBindigns(),
          child: LoginView(redirectTo: state.uri.queryParameters['redirectTo']),
        );
      },
      redirect: (context, state) {
        return RouteGuard.apply(state, [AuthGuardImpl(invert: true)]);
      },
    ),
    GoRoute(
      name: 'setup',
      path: RoutesHelper.setup,
      builder: (context, state) {
        return GetBindingsWrapper(
          binding: SetupBindings(),
          child: const SetupView(),
        );
      },
      redirect: (context, state) {
        // Se já existe empresa, impede acesso ao setup
        final hasCompany = Get.isRegistered<bool>(tag: 'hasCompany')
            ? Get.find<bool>(tag: 'hasCompany')
            : true;
        if (hasCompany) return RoutesHelper.login;
        return null;
      },
    ),
    GoRoute(
      name: 'switch-company',
      path: RoutesHelper.switchCompany,
      builder: (context, state) {
        return GetBindingsWrapper(
          binding: CompanySwitcherBindings(),
          child: const CompanySwitcherView(),
        );
      },
      redirect: (context, state) {
        return RouteGuard.apply(state, [AuthGuardImpl()]);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return GetBindingsWrapper(
          binding: HomeBindings(),
          child: HomeView(navigationShell: navigationShell, state: state),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'dashboard',
              path: RoutesHelper.dashboard,
              builder: (context, state) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              },
              redirect: (context, state) {
                // Aplica os guards primeiro
                final guardResult = RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                // Se houver redirecionamento dos guards, retorna ele
                if (guardResult != null) {
                  return guardResult;
                }
                // Caso contrário, redireciona para a rota principal do dashboard
                return '${RoutesHelper.dashboard}/main';
              },
              routes: [
                GoRoute(
                  name: 'dashboard_id',
                  path: PathsHelper.id,
                  builder: (context, state) {
                    return GetBindingsWrapper(
                      binding: DashboardBindigns(),
                      child: DashboardView(dashboardId: state.pathParameters['id']!),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- FORMULARIES
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'formularies',
              path: RoutesHelper.formularies,
              builder: (context, state) {
                return GetBindingsWrapper(binding: FormListBindings(), child: FormListView());
              },
              redirect: (context, state) {
                // if (appstateController.formHasUnsavedValues.value) {
                //   final param = state.pathParameters['id'] ?? 'new';
                //   return '${RoutesHelper.formularies}/$param';
                // }
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              // redirect: (context, state) => authRedirect(),
              routes: [
                GoRoute(
                  name: 'formulary manager',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: FormManagerBindings(),
                        child: FormManagerView(formId: state.pathParameters['id']!),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- ACTIVITIES
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'activities',
              path: RoutesHelper.activities,
              builder: (context, state) {
                return GetBindingsWrapper(binding: ActivityListBindings(), child: ActivityListView());
              },
              redirect: (context, state) async {
                final id = state.pathParameters['id'];
                if (id != null && id != 'new') {
                  final activity = await activityServices.findOne(id);
                  return activity.fold((l) => RoutesHelper.activities, (activity) {
                    if (activity['status'] != 'inactive') {
                      return RoutesHelper.activities; // impede acesso e redireciona
                    }
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  });
                }
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              // redirect: (context, state) => authRedirect(),
              routes: [
                GoRoute(
                  name: 'activities manager',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: ActivityManagerBindings(),
                        child: ActivityManagerView(activityId: state.pathParameters['id']!),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- TASKS
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'tasks',
              path: PathsHelper.tasks,
              pageBuilder: (context, state) {
                return _buildPageWithTransition(state, GetBindingsWrapper(binding: TaskListBindings(), child: TaskListView()));
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'task',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: TaskManagerBindings(),
                        child: TaskManagerView(taskId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- DEPARTMENTS
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'departments',
              path: RoutesHelper.departments,
              builder: (context, state) {
                return GetBindingsWrapper(binding: DepartmentListBindings(), child: DepartmentListView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'department',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: DepartmentFormBindings(),
                        child: DepartmentFormView(departmentId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- USERS
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'users',
              path: RoutesHelper.users,
              builder: (context, state) {
                return GetBindingsWrapper(binding: UserListBindings(), child: UserListView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'user',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: UserFormBindings(),
                        child: UserFormView(userId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- CURRENT USER PROFILE
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'current profile',
              path: RoutesHelper.loggedProfile,
              builder: (context, state) {
                return GetBindingsWrapper(binding: UserProfileBindings(), child: UserProfileView());
              },
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- PROFILES
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'profiles',
              path: RoutesHelper.profiles,
              builder: (context, state) {
                return GetBindingsWrapper(binding: ProfileListBindings(), child: ProfileListView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'profile',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: ProfileFormBindings(),
                        child: ProfileFormView(profileId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- CLIENTS
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'clients',
              path: RoutesHelper.clients,
              builder: (context, state) {
                return GetBindingsWrapper(binding: ClientListBindings(), child: ClientListView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'client',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: ClientManagerBindings(),
                        child: ClientManagerView(clientId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- COMPANIES
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'companies',
              path: RoutesHelper.companies,
              builder: (context, state) {
                return GetBindingsWrapper(binding: CompanyListBindings(), child: CompanyListView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
              },
              routes: [
                GoRoute(
                  name: 'company',
                  path: PathsHelper.id,
                  pageBuilder: (context, state) {
                    return _buildPageWithTransition(
                      state,
                      GetBindingsWrapper(
                        binding: CompanyManagerBindings(),
                        child: CompanyManagerView(companyId: state.pathParameters['id'] ?? ''),
                      ),
                    );
                  },
                  redirect: (context, state) {
                    return RouteGuard.apply(state, [AuthGuardImpl(), MenuAccessGuardImpl()]);
                  },
                ),
              ],
            ),
          ],
        ),
        // ----------------------------------------------------------------------------- SETTINGS
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: 'settings',
              path: RoutesHelper.settings,
              builder: (context, state) {
                return GetBindingsWrapper(binding: SettingsBindings(), child: SettingsView());
              },
              redirect: (context, state) {
                return RouteGuard.apply(state, [AuthGuardImpl()]);
              },
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundPage(),
);

// String? authRedirect() {
//   return authController.isAuthenticated ? null : RoutesHelper.login;
// }

CustomTransitionPage _buildPageWithTransition(GoRouterState state, Widget child) {
  // Essa função é somente para paginas internas após a primeira pagina da stack
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
        child: child,
      );
    },
  );
}

class GoRouterAuthListener extends ChangeNotifier {
  // GoRouterAuthListener() {
  //   authController.firebaseUser.listen((user) {
  //     notifyListeners();
  //   });
  // }
  GoRouterAuthListener() {
    authController.firebaseUser.listen((_) => notifyListeners());
    authController.isInitialized.listen((_) {
      notifyListeners();
    });
  }
}
