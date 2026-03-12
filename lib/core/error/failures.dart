import 'package:equatable/equatable.dart';

/// Базовый класс для всех ошибок в домене
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Ошибка локальной базы данных
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Ошибка: запрошенный ресурс не найден
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Ошибка валидации входных данных
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Непредвиденная ошибка
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
