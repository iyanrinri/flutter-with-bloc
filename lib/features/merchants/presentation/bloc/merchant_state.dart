import '../../domain/entities/merchant.dart';

class MerchantState {
  final bool isLoading;
  final List<Merchant> merchants;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const MerchantState({
    this.isLoading = false,
    this.merchants = const [],
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  MerchantState copyWith({
    bool? isLoading,
    List<Merchant>? merchants,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return MerchantState(
      isLoading: isLoading ?? this.isLoading,
      merchants: merchants ?? this.merchants,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}