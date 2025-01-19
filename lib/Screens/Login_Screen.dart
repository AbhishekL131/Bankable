

import 'package:fluenteer/Screens/Sign_Up_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_utilities/firebase_auth_methods.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  void ClearEmail(){
    setState(() {
      emailController.clear();
    });
  }

  void loginUser() async {
    bool success = await context.read<FirebaseAuthMethods>().loginWithEmail(
      email: emailController.text,
      password: passwordController.text,
      context: context,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: "app")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  void ToggleVisibility(){
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAFDF6),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:  25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 320,
                  child: Image(
                    image: AssetImage("assets/images/Login.webp"),
                  ),
                ),
              ),

              SizedBox(height: 10,),

              Text(
                "User Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Color(0xFF4A4A4A)
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: TextField(
                    controller: emailController,

                    decoration: InputDecoration(

                      labelText: "Enter Email",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear,size: 18,),
                        onPressed: ClearEmail,
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        size: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Color(0xFF00796B)
                        )
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color:  Color(0xFFBDBDBD),
                          width: 1.5
                        )
                      )
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscuringCharacter: "*",
                    obscureText: _obscureText,


                    decoration: InputDecoration(

                        labelText: "Enter Password",

                        prefixIcon: Icon(
                          Icons.password,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon : Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: ToggleVisibility,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                width: 1.5,
                                color: Color(0xFF00796B)
                            )
                        ),

                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color:  Color(0xFFBDBDBD),
                                width: 1.5
                            )
                        )
                    ),
                  ),
                ),
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      final email = emailController.text.trim();
                      context.read<FirebaseAuthMethods>().resetPassword(
                          email: email,
                          context: context
                      );
                    },
                    child: Text(
                      "Forgot Password ? ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(

                      onPressed: loginUser,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00897B)
                      ),

                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold

                        ),
                      )

                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't Have account?",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4A4A4A)
                    ),
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                    onTap: (){
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()
                          )
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent
                      ),
                    ),
                  )
                ],
              )



            ],
          ),
        ),

      ),
    );
  }
}