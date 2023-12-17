import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final productsData = Provider.of<ProductsProvider>(context,
        listen:
            false); // fetch data one time when screen is build for first time and never update
    final product = productsData.findById(productId);

    return Scaffold(
      /* appBar: AppBar(
        title: Text(product.title),
      ), */
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.title),
              background: Hero(
                tag: product.id!,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    product.description,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 800,
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
