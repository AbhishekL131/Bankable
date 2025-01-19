
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_utilities/firebase_auth_methods.dart';
import '../screens/login_screen.dart';


class MyDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final authMethods = Provider.of<FirebaseAuthMethods>(context);
    return Drawer(

      backgroundColor: Color(0xFFB2DFDB), // Light Teal background for a fresh and airy look
      child: Column(
        children: [

          FutureBuilder<DocumentSnapshot?>(
            future: authMethods.getUserData(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('User data not found.'));
              } else {
                String userName = snapshot.data!['Name'];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$userName",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black87, // Dark text for readability
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),


          SizedBox(height: 20),

          // Home Item
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: Text("HOME", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              leading: Icon(Icons.home, color: Colors.black87),
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ),

          // Settings Item
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: Text("SETTINGS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              leading: Icon(Icons.settings_outlined, color: Colors.black87),
              onTap: () {},
            ),
          ),

          // Logout Item
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: Text("LOGOUT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              leading: Icon(Icons.logout, color: Colors.black87),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                        title: Text("Sign Out"),
                        content: Text("Are you Sure?"),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await context.read<FirebaseAuthMethods>().signOut(context);
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "No",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );



  }

}