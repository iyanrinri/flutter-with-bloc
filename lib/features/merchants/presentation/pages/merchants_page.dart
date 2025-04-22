// merchants_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';
import 'package:yukngantri/features/merchants/presentation/bloc/merchant_bloc.dart';
import 'package:yukngantri/features/merchants/presentation/bloc/merchant_event.dart';
import 'package:yukngantri/features/merchants/presentation/bloc/merchant_state.dart';

import '../../domain/entities/merchant.dart';
import '../widgets/merchant_tile.dart';

class MerchantsPage extends StatefulWidget {
  static const routeName = '/merchants';

  const MerchantsPage({super.key});

  @override
  State<MerchantsPage> createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  late ScrollController _scrollController;
  final _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantBloc>().add(const FetchMerchants());
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
        !context.read<MerchantBloc>().state.isLoading) {
      context.read<MerchantBloc>().add(const FetchMerchants(isNextPage: true));
    }
  }

  void showMerchantDialog({Merchant? merchant}) {
    final nameController = TextEditingController(text: merchant?.name ?? '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(merchant == null ? 'Add Merchant' : 'Edit Merchant'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
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
                  final newMerchant = Merchant(
                    id: merchant?.id ?? 0,
                    name: nameController.text,
                  );
                  if (merchant == null) {
                    context.read<MerchantBloc>().add(CreateMerchant(newMerchant));
                  } else {
                    context.read<MerchantBloc>().add(UpdateMerchant(newMerchant));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  ListView _listItems(MerchantState state) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.merchants.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.merchants.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final merchant = state.merchants[index];
        return MerchantTile(
          merchant: merchant,
          onEdit: () => showMerchantDialog(merchant: merchant),
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                      'Are you sure you want to delete this merchant?',
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
              context.read<MerchantBloc>().add(DeleteMerchant(merchant.id));
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
          title: 'Merchants',
          titleIcon: const Icon(Icons.people),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showMerchantDialog(),
            child: const Icon(Icons.add),
          ),
          child: BlocConsumer<MerchantBloc, MerchantState>(
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
              if (state.merchants.isEmpty) {
                return const Center(child: Text('No merchants found'));
              }
              return RefreshIndicator(
                onRefresh: () async => context.read<MerchantBloc>().add(const FetchMerchants(isRefresh: true)),
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
                              context.read<MerchantBloc>()
                                  .add(FetchMerchants(isRefresh: true, query: value));
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
