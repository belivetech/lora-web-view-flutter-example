import 'package:flutter/material.dart';

class ProductBottomSheet extends StatefulWidget {
  const ProductBottomSheet({super.key});

  @override
  State<ProductBottomSheet> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Text('Products', style: theme.textTheme.headlineMedium)
      ],
    );
  }
}