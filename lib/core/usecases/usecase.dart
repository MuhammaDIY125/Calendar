import 'package:fpdart/fpdart.dart';

import 'package:calendar/core/error/failures.dart';

/// Базовый абстрактный класс для всех use case'ов.
///
/// [Type] — тип возвращаемого значения при успехе.
/// [Params] — параметры, принимаемые use case'ом.
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

/// Используется когда use case не принимает параметров
class NoParams {
  const NoParams();
}
