import '../../domain/entities/merchant.dart';

abstract class MerchantEvent {
  const MerchantEvent();
}

class FetchMerchants extends MerchantEvent {
  final bool isRefresh;
  final bool isNextPage;
  final String? query;

  const FetchMerchants({
    this.isRefresh = false,
    this.isNextPage = false,
    this.query,
  });
}

class CreateMerchant extends MerchantEvent {
  final Merchant merchant;
  const CreateMerchant(this.merchant);
}

class UpdateMerchant extends MerchantEvent {
  final Merchant merchant;
  const UpdateMerchant(this.merchant);
}

class DeleteMerchant extends MerchantEvent {
  final int id;
  const DeleteMerchant(this.id);
}