import '../../domain/entities/user.dart';

class UserState {
  final bool isLoading;
  final List<User> users;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const UserState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  UserState copyWith({
    bool? isLoading,
    List<User>? users,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}