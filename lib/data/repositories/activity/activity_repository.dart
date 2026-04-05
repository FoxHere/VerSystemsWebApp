import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';

abstract interface class ActivityRepository {
  Future<Either<RepositoryException, ActivityModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<ActivityModel>>> findAllActivities(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, String>> saveActivity(ActivityModel activityModel);
}
