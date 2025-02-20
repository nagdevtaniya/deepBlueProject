import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String mealsContributed = "0";
  String coinsEarned = "0";
  String rewards = "0";
  String foodSaved = "0";
  String userID = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    userID = user.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();

    if (userDoc.exists) {
      setState(() {
        _usernameController.text = userDoc['name'] ?? "Default Name";
        _phoneController.text = userDoc['mobile_number'] ?? "-";
        _addressController.text = userDoc['add'] ?? "Unknown Address";
        mealsContributed = userDoc['meals_contributed']?.toString() ?? "0";
        coinsEarned = userDoc['coins-earned']?.toString() ?? "0";
        rewards = userDoc['rewards']?.toString() ?? "0";
        foodSaved = "${userDoc['food-saved'] ?? "0"}kg";
        print(foodSaved);
      });
    }
  }

  void _updateUserData() async {
    if (userID.isEmpty) return;

    await FirebaseFirestore.instance.collection('users').doc(userID).update({
      'name': _usernameController.text,
      'mobile_number': _phoneController.text,
      'add': _addressController.text,
    });

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blue Box
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // White Box
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 130),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _isEditing ? buildEditableInfoRow("Username:", _usernameController) : buildInfoRow("Username:", _usernameController.text),
                        _isEditing ? buildEditableInfoRow("Phone Number:", _phoneController) : buildInfoRow("Phone Number:", _phoneController.text),
                        _isEditing ? buildEditableInfoRow("Address:", _addressController) : buildInfoRow("Address:", _addressController.text),
                        buildInfoRow("No of meals contributed:", mealsContributed),
                        buildInfoRow("Coins Earned:", coinsEarned),
                        buildInfoRow("Rewards:", rewards),
                        buildInfoRow("Amount of food saved:", foodSaved),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Edit Profile Button
                  Container(
                    margin: const EdgeInsets.all(25.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _updateUserData();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A148C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(_isEditing ? "Save Profile" : "Edit Profile"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Full-size Image and Add Button
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://media.istockphoto.com/id/1437816897/photo/business-woman-manager-or-human-resources-portrait-for-career-success-company-we-are-hiring.jpg?s=612x612&w=0&k=20&c=tyLvtzutRh22j9GqSGI33Z4HpIwv9vL_MZw_xOE19NQ='),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Handle picture addition
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4A148C),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the info rows
  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper method to build the editable info rows
  Widget buildEditableInfoRow(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
