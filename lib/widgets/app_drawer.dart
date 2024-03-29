import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';
import '../helpers/custom_route.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Hello Friend'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.payment),
              title: const Text('Orders'),
              onTap: () {
                // Navigator.of(context)
                //   .pushReplacementNamed(OrdersScreen.routeName),
                Navigator.of(context).pushReplacement(
                  CustomRoute(
                    builder: (ctx) => OrdersScreen(),
                  ),
                );
              }),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName),
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
              }),
        ],
      ),
    );
  }
}
