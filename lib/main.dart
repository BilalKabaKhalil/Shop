import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/order_provider.dart';
import './providers/cart_provider.dart';
import './providers/products_provider.dart';

import './screens/splash_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (ctx) => ProductsProvider(
              Provider.of<AuthProvider>(
                ctx,
                listen: false,
              ).getToken,
              Provider.of<AuthProvider>(
                ctx,
                listen: false,
              ).getUserId,
              []),
          update: (
            ctx,
            auth,
            previousProductsProvider,
          ) =>
              ProductsProvider(
            auth.getToken,
            auth.getUserId,
            previousProductsProvider == null
                ? []
                : previousProductsProvider.getProducts,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (ctx) => OrderProvider(
              Provider.of<AuthProvider>(
                ctx,
                listen: false,
              ).getToken,
              Provider.of<AuthProvider>(
                ctx,
                listen: false,
              ).getUserId,
              []),
          update: (context, auth, previousOrderProvider) => OrderProvider(
            auth.getToken,
            auth.getUserId,
            previousOrderProvider == null
                ? []
                : previousOrderProvider.getOrders,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.purple,
                secondary: Colors.deepOrange,
              ),
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
              }),
            ),
            routes: {
              '/': (_) => auth.isAuth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    ),
              ProductOverviewScreen.routeName: (_) => ProductOverviewScreen(),
              ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
              CartScreen.routeName: (_) => CartScreen(),
              OrdersScreen.routeName: (_) => OrdersScreen(),
              UserProductScreen.routeName: (_) => UserProductScreen(),
              EditProductScreen.routeName: (_) => EditProductScreen(),
            },
          );
        },
      ),
    );
  }
}
