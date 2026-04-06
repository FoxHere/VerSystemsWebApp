import 'package:versystems_app/config/helpers/routes/paths_helper.dart';

abstract class RoutesHelper {
  static const splash = PathsHelper.splash;
  static const setup = PathsHelper.setup;
  static const login = PathsHelper.login;
  static const dashboard = PathsHelper.dashboard;
  static const manager = PathsHelper.manager;
  static const tasks = PathsHelper.tasks;
  static const activities = PathsHelper.activities;
  static const formularies = PathsHelper.formularies;
  static const settings = PathsHelper.settings;
  static const formulariesManager = PathsHelper.formularies + PathsHelper.manager;
  static const activityManager = PathsHelper.activities + PathsHelper.manager;
  static const loggedProfile = PathsHelper.loggedProfile;
  static const profiles = PathsHelper.profiles;
  static const profilesManager = PathsHelper.profiles + PathsHelper.manager;
  static const users = PathsHelper.users;
  static const usersManager = PathsHelper.users + PathsHelper.manager;
  static const departments = PathsHelper.departments;
  static const departmentsManager = PathsHelper.departments + PathsHelper.manager;
  static const clients = PathsHelper.clients;
  static const clientManager = PathsHelper.clients + PathsHelper.manager;
  static const companies = PathsHelper.companies;
  static const companyManager = PathsHelper.companies + PathsHelper.manager;
  static const switchCompany = PathsHelper.switchCompany;
}
