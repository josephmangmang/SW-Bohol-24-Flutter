import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SW Bohol Restaurant',
      home: LoginPage(),
    );
  }
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: Login with Google implementation
          },
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
