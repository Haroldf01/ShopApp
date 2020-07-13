import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageURL,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    // isFavorite = !isFavorite;
    final updateProductsURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/products/$id.json';
    final response = await http.patch(updateProductsURL,
        body: json.encode({
          'isFavorite': isFavorite = !isFavorite,
        }));
    print(response.body);
    notifyListeners();
  }
}
