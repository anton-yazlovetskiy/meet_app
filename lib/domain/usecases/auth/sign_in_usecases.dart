import '../../repositories/index.dart';
import '../usecase.dart';

/// Usecase для входа через Google
class SignInWithGoogleUseCase extends UseCase<void, NoParams> {
  final AuthRepository authRepository;

  SignInWithGoogleUseCase(this.authRepository);

  @override
  Future<void> call(NoParams params) async {
    await authRepository.signInWithGoogle();
  }
}

/// Usecase для входа через Apple
class SignInWithAppleUseCase extends UseCase<void, NoParams> {
  final AuthRepository authRepository;

  SignInWithAppleUseCase(this.authRepository);

  @override
  Future<void> call(NoParams params) async {
    await authRepository.signInWithApple();
  }
}

/// Usecase для входа через Twitter
class SignInWithTwitterUseCase extends UseCase<void, NoParams> {
  final AuthRepository authRepository;

  SignInWithTwitterUseCase(this.authRepository);

  @override
  Future<void> call(NoParams params) async {
    await authRepository.signInWithTwitter();
  }
}

/// Usecase для выхода
class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository authRepository;

  SignOutUseCase(this.authRepository);

  @override
  Future<void> call(NoParams params) async {
    await authRepository.signOut();
  }
}

/// Params для AcceptLicenseUseCase
class AcceptLicenseParams {
  final String userId;
  AcceptLicenseParams({required this.userId});
}

/// Usecase для принятия лицензионного соглашения
class AcceptLicenseUseCase extends UseCase<void, AcceptLicenseParams> {
  final AuthRepository authRepository;

  AcceptLicenseUseCase(this.authRepository);

  @override
  Future<void> call(AcceptLicenseParams params) async {
    await authRepository.acceptLicense(params.userId);
  }
}
