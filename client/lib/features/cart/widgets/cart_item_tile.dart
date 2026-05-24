import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../core/widgets/price_text.dart';
import '../../../theme/app_theme.dart';

class CartItemTile extends StatelessWidget {
  final CartPizza item;
  final VoidCallback onRemove;

  const CartItemTile({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(
          item.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Left ${item.leftHalf.type.displayName} / Right ${item.rightHalf.type.displayName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceText(
              item.price,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            IconButton(
              tooltip: 'Remove',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
