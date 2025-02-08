import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventPage(),
    );
  }
}

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _currentIndex = 0;

  final List<String> _texts = [
    'Our app helps you organize events effortlessly. Plan and schedule your events with ease, ensuring that every detail is accounted for.',
    'Keep everyone on the same page with our collaboration features. Share event details with your team, send instant updates, and manage tasks efficiently.',
    'Track RSVPs, manage attendees, and analyze event performance all in one place.',
  ];

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Event Response Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No of Responses: 20'),
              SizedBox(height: 8),
              Text('Estimated No of Guests: 50'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _createEvent(Map<String, dynamic> eventData) async {
    try {
      // Create a new event in Firestore collection (automatically creates the collection)
      await FirebaseFirestore.instance.collection('events').add(eventData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event Created Successfully!")),
      );
    } catch (error) {
      print("Error creating event: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://t3.ftcdn.net/jpg/09/73/00/10/360_F_973001010_9jQNAezyjwE88UWaF6hYnLyEUDwM9cam.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Schedule an event',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _texts.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: Text(
                            _texts[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _texts.length,
                          (index) => GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(index,
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          width: 12,
                          height: 12,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.purple
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showPopup(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Past Event Response',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Sample event data to create
                          Map<String, dynamic> eventData = {
                            'eventTitle': 'Sample Event',
                            'date': '2025-12-31',
                            'time': '18:00',
                            'description': 'This is a sample event description.',
                            'place': 'Sample Location',
                            'createdAt': FieldValue.serverTimestamp(),
                          };
                          _createEvent(eventData);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Event()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'GET STARTED',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
