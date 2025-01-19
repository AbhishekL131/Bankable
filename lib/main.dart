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

  final FirebaseAuthMethods authMethods = FirebaseAuthMethods(FirebaseAuth.instance);


  int _page = 0;

  onPageChanged(int page){
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


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 10,
        currentIndex: _page,
        onTap: onPageChanged,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _page == 0
                ? ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [Color(0xFF00BFA5), Color(0xFF1DE9B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect);
              },
              child: Icon(Icons.home, color: Colors.white),
            )
                : Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _page == 1
                ? ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [Color(0xFF26C6DA), Color(0xFF00E5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect);
              },
              child: Icon(Icons.leaderboard, color: Colors.white),
            )
                : Icon(Icons.leaderboard_outlined),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: _page == 2
                ? ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect);
              },
              child: Icon(Icons.file_copy, color: Colors.white),
            )
                : Icon(Icons.file_copy_outlined),
            label: "Report",
          ),
          BottomNavigationBarItem(
            icon: _page == 3
                ? ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect);
              },
              child: Icon(Icons.person, color: Colors.white),
            )
                : Icon(Icons.person_outlined),
            label: "Profile",
          ),
        ],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.teal,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        selectedItemColor: Colors.teal.shade900,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
      ),


    );
  }
}
