// users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';
import 'package:yukngantri/features/users/presentation/bloc/user_bloc.dart';
import 'package:yukngantri/features/users/presentation/bloc/user_event.dart';
import 'package:yukngantri/features/users/presentation/bloc/user_state.dart';

import '../../domain/entities/user.dart';
import '../widgets/user_tile.dart';

class UsersPage extends StatefulWidget {
  static const routeName = '/users';

  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late ScrollController _scrollController;
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const FetchUsers());
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !context.read<UserBloc>().state.isLoading) {
      context.read<UserBloc>().add(const FetchUsers(isNextPage: true));
    }
  }

  void showUserDialog({User? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newUser = User(
                    id: user?.id ?? 0,
                    name: nameController.text,
                    email: emailController.text, role: 'USER',
                  );
                  if (user == null) {
                    context.read<UserBloc>().add(CreateUser(newUser));
                  } else {
                    context.read<UserBloc>().add(UpdateUser(newUser));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  ListView _listItems(UserState state) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.users.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.users.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.users[index];
        return UserTile(
          user: user,
          onEdit: () => showUserDialog(user: user),
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                      'Are you sure you want to delete this user?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            );
            if (confirm == true) {
              context.read<UserBloc>().add(DeleteUser(user.id));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  DoubleBackToExitWrapper(
        child: MainLayout(
          title: 'Users',
          titleIcon: const Icon(Icons.people),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showUserDialog(),
            child: const Icon(Icons.add),
          ),
          child: BlocConsumer<UserBloc, UserState>(
            listener: (context, state) {
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.users.isEmpty) {
                return const Center(child: Text('No users found'));
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<UserBloc>().add(const FetchUsers(isRefresh: true)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _queryController,
                        decoration: InputDecoration(
                          labelText: 'Cari Pengguna',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onSubmitted:
                            (value) {
                              context.read<UserBloc>()
                                  .add(FetchUsers(isRefresh: true, query: value));
                            }
                      ),
                    ),
                    Expanded(child: _listItems(state)),
                  ],
                ),
              );
            },
          ),
        ),
    );
  }
}
