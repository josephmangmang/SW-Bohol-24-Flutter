import 'dart:async';

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

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({super.key});

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
