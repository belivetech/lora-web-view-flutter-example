import 'package:flutter/material.dart';

class ProductDetailScreenArguments {
  final String sku;
  final String title;
  final String? description;

  ProductDetailScreenArguments({
    required this.sku,
    required this.title,
    this.description,
  });
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.sku,
    required this.title,
    this.description,
  });

  static const routeName = '/product-detail';
  final String sku;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: Image.network(
                'https://believe.sg/wp-content/uploads/2023/01/Belive-page-banner.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList.list(children: [
            const SizedBox(height: 8),
            Text(
              description ?? "Product Description",
              style: theme.textTheme.bodySmall,
            ),
          ]),
        ],
      ),
    );
  }
}
