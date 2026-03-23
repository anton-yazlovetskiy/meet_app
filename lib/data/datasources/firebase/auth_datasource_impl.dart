import '../../../domain/index.dart';
import '../../../data/models/index.dart';
import 'auth_datasource.dart';

/// Mock реализация FirebaseAuthDataSource для локальной разработки
class MockFirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<UserModel> signInWithGoogle() async {
    _currentUser = UserModel(
      id: 'user_1',
      name: 'Test User (Google)',
      email: 'test.google@example.com',
      rating: 5.0,
      status: UserStatus.active,
      role: UserRole.user,
      premiumStatus: PremiumStatus.free,
      acceptedLicense: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithApple() async {
    _currentUser = UserModel(
      id: 'user_2',
      name: 'Test User (Apple)',
      email: 'test.apple@example.com',
      rating: 4.5,
      status: UserStatus.active,
      role: UserRole.user,
      premiumStatus: PremiumStatus.physicalPremium,
      acceptedLicense: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithTwitter() async {
    _currentUser = UserModel(
      id: 'user_3',
      name: 'Test User (Twitter)',
      email: 'test.twitter@example.com',
      rating: 4.0,
      status: UserStatus.active,
      role: UserRole.user,
      premiumStatus: PremiumStatus.businessLevel2,
      acceptedLicense: false,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<bool> hasAcceptedLicense(String userId) async {
    return _currentUser?.acceptedLicense ?? false;
  }

  @override
  Future<void> acceptLicense(String userId) async {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        rating: _currentUser!.rating,
        status: _currentUser!.status,
        role: _currentUser!.role,
        premiumStatus: _currentUser!.premiumStatus,
        acceptedLicense: true,
      );
    }
  }

  @override
  Stream<UserModel?> authStateChanges() async* {
    yield _currentUser;
  }
}
