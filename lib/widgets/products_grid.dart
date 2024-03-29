import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  const ProductsGrid(this.showFavorites);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavorites ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      // this .value approach is perfect when you are not using the context and
      // it is always recommended to use this value constructor whenever using
      // listView builder or such builder function, to the data will be updated
      // along with the listView widget tree
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
//        create: (c) => products[index],
        value: products[index],
        child: ProductItem(
//              products[index].id,
//              products[index].title,
//              products[index].imageURL,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
