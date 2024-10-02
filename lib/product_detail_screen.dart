import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Product title',
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
              'Product description',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Product description',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Product description',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Product description',
              style: theme.textTheme.bodySmall,
            ),
          ]),
        ],
      ),
    );
  }
}
