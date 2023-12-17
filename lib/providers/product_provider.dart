import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  ProductProvider(
      {this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String? authToken, String? userId) async {
    final url = Uri.parse(
        'https://flutter-update-123232-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    notifyListeners();

    try {
      final res = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );

      if (res.statusCode >= 400) {
        throw HttpException('Could not toggle favorite state to the product.');
      }
    } catch (_) {
      isFavorite = oldStatus;
      notifyListeners();
      rethrow;
    }
  }
}
