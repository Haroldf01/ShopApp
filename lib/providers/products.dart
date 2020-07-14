import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import 'product_model.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageURL:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageURL:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

//  var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get items {
//    if (_showFavoritesOnly) {
//      return _items.where((prodItem) => prodItem.isFavorite).toList();
//    }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

//  void showFavoritesOnly() {
//    _showFavoritesOnly = true;
//    notifyListeners();
//  }
//
//  void showAllItems() {
//    _showFavoritesOnly = false;
//    notifyListeners();
//  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterURL = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final getProductsURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/products.json?auth=$authToken&$filterURL';
    final getFavoritesOfIdUserURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
    try {
      final response = await http.get(getProductsURL);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) return;

      final favoriteResponse = await http.get(getFavoritesOfIdUserURL);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((key, prodValue) {
        loadedProducts.add(Product(
          id: key, // productID sent from firebase server
          title: prodValue['title'],
          description: prodValue['description'],
          price: prodValue['price'],
          imageURL: prodValue['imageURL'],
          isFavorite: favoriteData == null ? false : favoriteData[key] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProducts(Product product) async {
    final addProductsURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/products.json?auth=$authToken';
    // NOTE: async and await is more readable and better way to write the
    // .then and .catcherror function of the future
    try {
      final response = await http.post(
        addProductsURL,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageURL': product.imageURL,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageURL: product.imageURL,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // NOTE: below statement adds the product to the start of the list.
    // _items.insert(0, newProduct);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final updateProductsURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/products/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      await http.patch(
        updateProductsURL,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageURL': newProduct.imageURL,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final deleteProductURL =
        'https://flutter-shop-app-dd3c0.firebaseio.com/products/$id.json?auth=$authToken';

    // IMPORTANT: this type of deleting is known as optimistic updating.
    // if no error so delete it completely or else repopulate the item into the list.
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(deleteProductURL);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HTTPException(
          'Something went wrong. Could not delete the product.');
    }
    existingProduct = null;
  }
}
