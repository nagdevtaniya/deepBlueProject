import 'package:flutter/material.dart';
import 'volunteer_details.dart';

void main() {
  runApp(RecipientDetailsApp());
}

class RecipientDetailsApp extends StatelessWidget {
  const RecipientDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecipientDetailsPage(),
    );
  }
}

class RecipientDetailsPage extends StatelessWidget {
  const RecipientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFFFEBEE)], // Light purple to pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple,
              title: Text('Recipient Details'),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24), // Extra margin from the app bar

                    // Name Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Name:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'XYZ', // Replace with long text to test wrapping
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24), // Increased vertical spacing

                    // Address Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Address:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '123 XYZ Street, Some City, Some Country, with a very long description to test text wrapping.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24), // Increased vertical spacing

                    // Contact Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Contact:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '1234567890',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Select Mode of Delivery:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: 'By Volunteer (Default)',
                        items: [
                          DropdownMenuItem(
                            value: 'By Volunteer (Default)',
                            child: Text('By Volunteer (Default)'),
                          ),
                          DropdownMenuItem(
                            value: 'By Donor',
                            child: Text('By Donor'),
                          ),
                          DropdownMenuItem(
                            value: 'By Recipient',
                            child: Text('By Recipient'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                    SizedBox(height: 68), // Increased vertical spacing for Submit Button

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>VolunteerDetailsPage()), // Replace CreateEvent with your target page
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

