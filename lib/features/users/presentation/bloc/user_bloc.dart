import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/features/users/domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const UserState()) {
    on<FetchUsers>(_onFetchUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    if (event.isRefresh) {
      emit(const UserState());
    }
    if (!state.hasMore && !event.isRefresh) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final users = await repository.getUsers(
        page: event.isNextPage ? state.currentPage + 1 : 1,
        query: event.query,
      );
      final newUsers = event.isRefresh || event.isNextPage
          ? [...state.users, ...users]
          : users;
      emit(state.copyWith(users: newUsers, isLoading: false, hasMore: users.length >= 10,
        currentPage: event.isNextPage ? state.currentPage + 1 : 1));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.createUser(event.user);
      final users = await repository.getUsers();
      emit(state.copyWith(users: users, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.updateUser(event.user);
      final users = await repository.getUsers();
      emit(state.copyWith(users: users, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.deleteUser(event.id);
      final users = await repository.getUsers();
      emit(state.copyWith(users: users, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}