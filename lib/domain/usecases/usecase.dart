/// Базовый класс для всех usecases
abstract class UseCase<Type, Params> {
  /// Выполнить usecase с параметрами
  Future<Type> call(Params params);
}

/// NoParams для usecases без параметров
class NoParams {
  const NoParams();
}
