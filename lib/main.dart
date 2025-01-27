import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluenteer/Screens/HomeScreen.dart';
import 'package:fluenteer/Screens/Reports.dart';
import 'package:fluenteer/Screens/ai_screen.dart';
import 'package:fluenteer/Screens/transactions.dart';
import 'package:fluenteer/Screens/Profile.dart';
import 'package:fluenteer/Screens/Splash_Screen.dart';
import 'package:fluenteer/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';

import 'components/consts.dart';
import 'firebase_options.dart';
import 'firebase_utilities/firebase_auth_methods.dart';

Future<void> main() async {
  Gemini.init(apiKey: GEMINI_API_KEY);
  //await Gemini.instance.initialize(apiKey: "AIzaSyAPul-BOjO0dBtLs61HXSu8eUCNgRD_Pd0");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {




  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthMethods>(
          create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
        ),
        StreamProvider(
            create: (context) => context.read<FirebaseAuthMethods>().authState,
            initialData: null
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseAuthMethods authMethods = FirebaseAuthMethods(
      FirebaseAuth.instance);


  int _page = 0;

  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    HomeScreen(),
    Transactions(),
    Reports(),
    Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: IndexedStack(
        children: pages,
        index: _page,
      ),


      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),

        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _page,
            onTap: onPageChanged,
            type: BottomNavigationBarType.fixed,
            items: [
              _buildNavItem(0, Icons.home, Icons.home_outlined, "Home",
                  [Color(0xFFFF6B6B), Color(0xFFFFE66D)]),
              _buildNavItem(1, Icons.leaderboard, Icons.leaderboard_outlined,
                  "Transactions", [Color(0xFF4ECDC4), Color(0xFF45B7D1)]),
              _buildNavItem(
                  2, Icons.file_copy, Icons.file_copy_outlined, "Report",
                  [Color(0xFFFF8C42), Color(0xFFFFF275)]),
              _buildNavItem(3, Icons.person, Icons.person_outlined, "Profile",
                  [Color(0xFF6A0572), Color(0xFFAB83A1)]),
            ],
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.white,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
          ),
        ),
      ),

    );
  }

  BottomNavigationBarItem _buildNavItem(int index, IconData selectedIcon,
      IconData unselectedIcon, String label, List<Color> gradientColors) {
    return BottomNavigationBarItem(
      icon: _page == index
          ? Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(selectedIcon, color: Colors.white, size: 28),
      )
          : Icon(unselectedIcon, color: Colors.white70, size: 24),
      label: label,
    );
  }
}
