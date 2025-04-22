import '../entities/merchant.dart';

abstract class MerchantRepository {
  Future<List<Merchant>> getMerchants({int page = 1, String? query});
  Future<void> createMerchant(Merchant merchant);
  Future<void> updateMerchant(Merchant merchant);
  Future<void> deleteMerchant(int id);
}