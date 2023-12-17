import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/user_product_item.dart';

import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = 'user-product';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<ProductsProvider>(
      ctx,
      listen: false,
    ).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Products',
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(
              Icons.add,
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductsProvider>(
                  builder:(context, productsData, _) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (_, index) => Column(
                        children: <Widget>[
                          UserProductItem(
                            id: productsData.getProducts[index].id!,
                            title: productsData.getProducts[index].title,
                            imageUrl: productsData.getProducts[index].imageUrl,
                          ),
                          const Divider(),
                        ],
                      ),
                      itemCount: productsData.getProducts.length,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
