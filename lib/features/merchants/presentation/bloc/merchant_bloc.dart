import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/features/merchants/domain/repositories/merchant_repository.dart';
import 'merchant_event.dart';
import 'merchant_state.dart';

class MerchantBloc extends Bloc<MerchantEvent, MerchantState> {
  final MerchantRepository repository;

  MerchantBloc({required this.repository}) : super(const MerchantState()) {
    on<FetchMerchants>(_onFetchMerchants);
    on<CreateMerchant>(_onCreateMerchant);
    on<UpdateMerchant>(_onUpdateMerchant);
    on<DeleteMerchant>(_onDeleteMerchant);
  }

  Future<void> _onFetchMerchants(FetchMerchants event, Emitter<MerchantState> emit) async {
    if (event.isRefresh) {
      emit(const MerchantState());
    }
    if (!state.hasMore && !event.isRefresh) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final merchants = await repository.getMerchants(
        page: event.isNextPage ? state.currentPage + 1 : 1,
        query: event.query,
      );
      final newMerchants = event.isRefresh || event.isNextPage
          ? [...state.merchants, ...merchants]
          : merchants;
      emit(state.copyWith(merchants: newMerchants, isLoading: false, hasMore: merchants.length >= 10,
        currentPage: event.isNextPage ? state.currentPage + 1 : 1));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateMerchant(CreateMerchant event, Emitter<MerchantState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.createMerchant(event.merchant);
      final merchants = await repository.getMerchants();
      emit(state.copyWith(merchants: merchants, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateMerchant(UpdateMerchant event, Emitter<MerchantState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.updateMerchant(event.merchant);
      final merchants = await repository.getMerchants();
      emit(state.copyWith(merchants: merchants, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteMerchant(DeleteMerchant event, Emitter<MerchantState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.deleteMerchant(event.id);
      final merchants = await repository.getMerchants();
      emit(state.copyWith(merchants: merchants, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}