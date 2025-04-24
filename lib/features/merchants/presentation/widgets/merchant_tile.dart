import 'package:flutter/material.dart';

import '../../domain/entities/merchant.dart';

class MerchantTile extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MerchantTile({
    super.key,
    required this.merchant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(merchant.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Created: ${merchant.createdAt}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
