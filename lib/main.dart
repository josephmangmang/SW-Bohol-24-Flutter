import 'package:flutter/material.dart';

void main() {
  runApp(const RestaurantListPage());
}

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant List',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant List'),
        ),
        body: ListView(
          children: const <Widget>[
            ListTile(
              title: Text('The Old Plantation'),
              subtitle: Text('Tagbilaran Bohol'),
              trailing: Text('₱200-₱1000'),
            ),
            ListTile(
              title: Text('BeeFarm'),
              subtitle: Text('Tagbilaran Bohol'),
              trailing: Text('₱200-₱1000'),
            ),
            ListTile(
              title: Text('Chido Cafe'),
              subtitle: Text('Tagbilaran Bohol'),
              trailing: Text('₱200-₱1000'),
            ),
            ListTile(
              title: Text('Chamba Resto'),
              subtitle: Text('Tagbilaran Bohol'),
              trailing: Text('₱200-₱1000'),
            ),
          ],
        ),
      ),
    );
  }
}