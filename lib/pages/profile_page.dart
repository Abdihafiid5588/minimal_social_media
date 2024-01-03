import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimal_social_media/components/my_back_button.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // current logged in user
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  void _showEditUsernameDialog() {
    String newUsername = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: InputDecoration(labelText: 'New Username'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateUsername(newUsername);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateUsername(String newUsername) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({'username': newUsername})
        .then((value) {
      setState(() {}); // Refresh the UI to reflect the updated username
    }).catchError((error) {
      print("Failed to update username: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // error
          else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          // data received
          else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();

            return Center(  
              child: Column(
                children: [
                  // back button
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 50.0,
                      left: 25,
                    ),
                    child: Row(
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // profile pic
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Icon(
                      Icons.person,
                      size: 64,
                    ),
                  ),
                  // username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user!['username'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditUsernameDialog();
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // email
                  Text(
                    user['email'],
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Text("No data");
          }
        },
      ),
    );
  }
}
