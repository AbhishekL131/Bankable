

import 'dart:ffi';

import 'package:fluenteer/Screens/Login_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_utilities/firebase_auth_methods.dart';

class SignUpScreen extends StatefulWidget{
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void signUpUser() async {
    context.read<FirebaseAuthMethods>().signUpWithEmail(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      context: context,
    );




  }


  bool _obscureText = true;

  void ToggleVisibility(){
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void ClearName(){
    setState(() {
      nameController.clear();
    });
  }

  void ClearEmail(){
    setState(() {
      emailController.clear();
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
                    image: AssetImage("assets/images/Sign_up.webp"),
                  ),
                ),
              ),

              SizedBox(height: 10,),

              Text(
                "SignUp",
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
                    controller: nameController,

                    decoration: InputDecoration(

                        labelText: "Enter Name",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear,size: 18,),
                          onPressed: ClearName,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
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


              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(

                      onPressed: signUpUser,

                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00897B)
                      ),

                      child: Text(
                        "Sign Up",
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
                    "Already Have account?",
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
                             builder: (context) => LoginScreen()
                         )
                      );
                    },
                    child: Text(
                      "Login",
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