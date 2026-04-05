
import 'package:versystems_app/config/exceptions/repository_exception.dart';
import 'package:versystems_app/config/fp/either.dart';
import 'package:versystems_app/config/fp/unit.dart';
import 'package:versystems_app/data/models/activity/activity_model.dart';
import 'package:versystems_app/ui/shared/components/image_picker/image_item_model.dart';

abstract interface class TaskRepository {
  Future<Either<RepositoryException, ActivityModel?>> findOneById(String id);
  Future<Either<RepositoryException, List<ActivityModel>>> findAllTasks(
    Map<String, dynamic> filters,
  );
  Future<Either<RepositoryException, Unit>> saveTask(
    ActivityModel activityModel,
    List<ImageItemModel> imagesToRemove,
  );
}
