// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_provider.dart';
import '../models/http_exception.dart';
// import '../data/products_data.dart';

class ProductsProvider with ChangeNotifier {
  // List<ProductProvider> _products = DUMMY_PRODUCTS;
  List<ProductProvider> _products = [];

  final String? authToken;
  final String? userId;

  ProductsProvider(
    this.authToken,
    this.userId,
    this._products,
  );

  List<ProductProvider> get getProducts {
    return [..._products];
  }

  List<ProductProvider> get getFavorites {
    return _products.where((product) => product.isFavorite).toList();
  }

  ProductProvider findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://flutter-update-123232-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final res = await http.get(url);

      final extractedData = json.decode(res.body) as Map<String, dynamic>?;
      final List<ProductProvider> loadedProducts = [];

      if (extractedData == null) {
        return;
      }

      final urlFavorite = Uri.parse(
          'https://flutter-update-123232-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');

      final favoriteResponse = await http.get(urlFavorite);

      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(
          ProductProvider(
            id: prodID,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodID] ?? false,
          ),
        );
      });

      _products = loadedProducts;

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    final url = Uri.parse(
        'https://flutter-update-123232-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final res = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      final newProduct = ProductProvider(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _products.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, ProductProvider product) async {
    final prodIndex = _products.indexWhere((product) => product.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-update-123232-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }),
      );
      _products[prodIndex] = product;
      notifyListeners();
    } else {
      print('...');
    }
  }

  /* void deleteProduct(String id) {
    final url = Uri.parse(
        'https://flutter-update-123232-default-rtdb.firebaseio.com/products/$id.json');
    final existingProductIndex =
        _products.indexWhere((product) => product.id == id);
    ProductProvider? existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    http.delete(url).then((res) {
      if (res.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
      existingProduct = null;
    }).catchError((_) {
      _products.insert(existingProductIndex, existingProduct!);
      notifyListeners();
    });
  } */

  Future deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-update-123232-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex =
        _products.indexWhere((product) => product.id == id);

    ProductProvider? existingProduct = _products[existingProductIndex];

    _products.removeAt(existingProductIndex);

    notifyListeners();

    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
