import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/order_provider.dart' show OrderProvider;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchAndSetOrders(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (dataSnapShot.error != null) {
            return const Center(
              child: Text(
                'An error occurred!',
              ),
            );
          } else {
            return Consumer<OrderProvider>(
              builder: (context, orderData, child) =>
                  orderData.getOrders.length == 0
                      ? const Center(
                        child: Text('There are no orders added yet to show',),
                      )
                      : ListView.builder(
                          itemBuilder: (_, index) => OrderItem(
                            orderData.getOrders[index],
                          ),
                          itemCount: orderData.countOrders(),
                        ),
            );
          }
        },
      ),
    );
  }
}
