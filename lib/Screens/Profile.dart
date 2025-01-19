
import 'package:fluenteer/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_utilities/firebase_auth_methods.dart';
import '../screens/login_screen.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF00897B),
        centerTitle: true,
        elevation: 4.0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150'), // Replace with the profile picture URL
                backgroundColor: Colors.grey.shade300,
              ),
              SizedBox(height: 15),

              // User Name
              Text(
                "Abhishek Londhe", // Replace with user data
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 8),

              // Email
              Text(
                "abhishek.londhe@example.com", // Replace with user data
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),

              // Editable Info Section
              Card(
                color: Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF00897B)),
                  title: Text("Edit Profile"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to edit profile screen
                  },
                ),
              ),

              // Divider
              SizedBox(height: 15),

              // Settings
              Card(
                color: Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.lock, color: Color(0xFF00897B)),
                      title: Text("Change Password"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to change password screen
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.notifications, color: Color(0xFF00897B)),
                      title: Text("Notifications"),
                      trailing: Switch(
                        value: true,
                        onChanged: (bool value) {
                          // Handle notification toggle
                        },
                        activeColor: Color(0xFF00897B),
                      ),
                    ),
                  ],
                ),
              ),

              // Additional Options
              SizedBox(height: 15),
              Card(
                color: Color(0xFFF4F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info, color: Color(0xFF00897B)),
                      title: Text("About App"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to about app screen
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text("Logout"),
                      trailing: Icon(Icons.arrow_forward_ios),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
