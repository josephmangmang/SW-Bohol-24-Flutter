import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

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
    return MaterialApp(
      title: 'SW Bohol Restaurant',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        primaryColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
      home: const LoginPage(),
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
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred'),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Hey Hola!, Good Afternoon!',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                // logout
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.logout),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                                  ),
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
                            // all category horizontal list
                            const SizedBox(height: 16),

                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for restaurants',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'All Categories',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  iconAlignment: IconAlignment.end,
                                  onPressed: () {},
                                  label: const Text('See All'),
                                  icon: const Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final category in ['All', 'Pizza', 'Burger', 'Pasta', 'Dessert', 'Drinks'])
                                    Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: category == 'All' ? Colors.orange.shade300 : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.fastfood,
                                            color: category == 'All' ? Colors.white : Colors.orange,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            category,
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Find your favorite restaurant',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  iconAlignment: IconAlignment.end,
                                  onPressed: () {},
                                  label: const Text('See All'),
                                  icon: const Icon(Icons.keyboard_arrow_right),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate:
                          SliverChildBuilderDelegate(childCount: snapshot.data?.docs.length ?? 0, (context, index) {
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
                                    Hero(
                                      tag: restaurant['landscapeImage'],
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: restaurant['landscapeImage'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // favorite button
                                    Positioned(
                                      bottom: 8,
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
                                                content: Text(
                                                    isUserFavorite ? 'Removed from favorites' : 'Added to favorites'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        restaurant['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(restaurant['price'].toString()),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Text(restaurant['address'], style: GoogleFonts.inter(color: Colors.grey)),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
        ),
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
      body: CustomScrollView(
        // collapsing app bar
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            snap: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
              ),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
            actions: [
              IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {},
                icon: const Icon(Icons.share),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: restaurant['landscapeImage'],
                child: CachedNetworkImage(
                  imageUrl: restaurant['landscapeImage'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant['name'],
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                          restaurant['address'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      restaurant['description'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // portrait image
                    CachedNetworkImage(
                      imageUrl: restaurant['portraitImage'],
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ]),
          ),
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
      body: SafeArea(
        child: Stack(
          children: [
            SvgPicture.asset('assets/abstract_circle.svg'),
            Center(child: Lottie.asset('assets/Animation - 1723217554215.json')),
            Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Let's Get Started",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Food is life!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      signInWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 62)),
                    child: const Text('Login with Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        )),
                  ),
                ],
              ),
            ),
          ],
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
