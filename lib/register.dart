import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'package:flutter/material.dart';
import 'homePage.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RegisterPage({super.key});

  // Pass context as a parameter
  Future<void> _signUp(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Create a new user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user object
      User? user = userCredential.user;

      if (user != null) {
        // Add the user's email and name to Firestore
        await _addUserToFirestore(user, context);

        // Navigate to HomePage after successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // Adjust HomePage if needed
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The email is already in use.';
      }
      _showErrorDialog(context, errorMessage); // Pass context to the error dialog
    }
  }

  // Function to add the user's email and name to Firestore
  Future<void> _addUserToFirestore(User user, BuildContext context) async {
    try {
      // Reference to the Firestore collection 'users'
      CollectionReference usersRef = _firestore.collection('users');
      // Add user data under the user's UID
      await usersRef.doc(user.uid).set({
        'email': user.email,  // Store the email
        'name': user.email?.split('@')[0] ?? 'Anonymous',  // Store the name (default to 'Anonymous' if null)
        'mobile_number': '-',
        'add': '-',
        'meals_contributed': 0,
        'coins-earned': 0,
        'rewards': '-',
        'food-saved': '0kg'
      });

      print('User data added to Firestore!');
    } catch (e) {
      print('Error adding user data to Firestore: $e');
      _showErrorDialog(context, 'Failed to save user data. Please try again.');
    }
  }

  // Pass context to the showErrorDialog method
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signUp(context), // Pass context to _signUp
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
