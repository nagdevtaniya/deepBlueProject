import 'package:flutter/material.dart';

class VolunteerDetailsPage extends StatelessWidget {
  const VolunteerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white], // Light purple to pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF4A148C),
              title: Text('Volunteer Details'),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),

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
                      Expanded(
                        child: Text(
                          'John Doe',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

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
                      Expanded(
                        child: Text(
                          '1234567890',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Status
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.purple[100],
                                  radius: 30,
                                  child: Icon(
                                    Icons.volunteer_activism, // Volunteer icon
                                    color: Color(0xFF4A148C),
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Volunteer',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              height: 2,
                              width: 40,
                              color: Colors.grey,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.pink[100],
                                  radius: 30,
                                  child: Icon(
                                    Icons.local_shipping, // Pickup icon
                                    color: Color(0xFF4A148C),
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pick up',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Container(
                              height: 2,
                              width: 40,
                              color: Colors.grey,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  radius: 30,
                                  child: Icon(
                                    Icons.emoji_people, // Recipient icon
                                    color: Color(0xFF4A148C),
                                    size: 30,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Recipient',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
