import '../../domain/entities/user.dart';

abstract class UserEvent {
  const UserEvent();
}

class FetchUsers extends UserEvent {
  final bool isRefresh;
  final bool isNextPage;
  final String? query;

  const FetchUsers({
    this.isRefresh = false,
    this.isNextPage = false,
    this.query,
  });
}

class CreateUser extends UserEvent {
  final User user;
  const CreateUser(this.user);
}

class UpdateUser extends UserEvent {
  final User user;
  const UpdateUser(this.user);
}

class DeleteUser extends UserEvent {
  final int id;
  const DeleteUser(this.id);
}