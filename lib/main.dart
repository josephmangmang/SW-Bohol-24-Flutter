import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  List userFavorites = [];

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamSubscription;

  @override
  void initState() {
    super.initState();
    // listen for user favorite list change and store in variable
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      streamSubscription = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().listen((event) {
        final List<dynamic> favorites = event.data()?['favorites'] ?? [];
        print('User favorites: $favorites');
        setState(() {
          userFavorites = favorites;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant List',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant List'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred'),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final restaurant = snapshot.data!.docs[index].data();
                  final isUserFavorite = userFavorites.contains(restaurant['id']);
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailPage(restaurant: restaurant),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                restaurant['landscapeImage'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              // favorite button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    isUserFavorite ? Icons.favorite : Icons.favorite_border,
                                    size: 32,
                                  ),
                                  color: isUserFavorite ? Colors.red : Colors.white,
                                  onPressed: () {
                                    // add the restaurant id to the user's favorite list
                                    final String id = restaurant['id'];
                                    final User? user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      final List<dynamic> favorites = List.from(userFavorites);
                                      if (isUserFavorite) {
                                        favorites.remove(id);
                                      } else {
                                        favorites.add(id);
                                      }
                                      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                        'favorites': favorites,
                                      });

                                      // show snackbar
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(isUserFavorite ? 'Removed from favorites' : 'Added to favorites'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                restaurant['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(restaurant['price'].toString()),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(restaurant['address']),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({super.key, required this.restaurant});

  final Map<String, dynamic> restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant['name']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            restaurant['landscapeImage'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Text(
            restaurant['address'],
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            restaurant['price'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(restaurant['description']),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late StreamSubscription<User?>? streamSubscription;

  @override
  void initState() {
    // check if user is already logged in
    streamSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RestaurantListPage()),
        );
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            signInWithGoogle();
          },
          child: const Text('Login with Google'),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn().signOut();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
