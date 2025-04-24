import 'package:yukngantri/features/merchants/domain/entities/merchant.dart';

class MerchantModel {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  MerchantModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    print(json);
    return MerchantModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      name: json['name'] as String? ?? '',
      createdAt: json['created_at_human'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt
    };
  }

  Merchant toEntity() {
    return Merchant(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }
}