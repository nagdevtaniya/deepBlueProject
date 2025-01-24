import 'package:flutter/material.dart';
import 'create_event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventPage(),
    );
  }
}

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  int _currentIndex = 0;

  final List<String> _texts = [
    'Our app helps you organize events effortlessly. Plan and schedule your events with ease, ensuring that every detail is accounted for. With a user-friendly interface and smart tools, creating an event becomes a hassle-free experience.',
    'Keep everyone on the same page with our collaboration features. Share event details with your team, send instant updates, and manage tasks efficiently to ensure a successful event execution.',
    'Track RSVPs, manage attendees, and analyze event performance all in one place. From tracking confirmations to sending reminders, our app provides all the tools you need to host a seamless event.',
  ];

  PageController _pageController = PageController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://t3.ftcdn.net/jpg/09/73/00/10/360_F_973001010_9jQNAezyjwE88UWaF6hYnLyEUDwM9cam.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // White Interface Positioned from 60% of the Screen to Bottom
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
                  // Title
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
                  // PageView for Scrolling and Text
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
                  // Indicator Dots
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
                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Past Event Response Button
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
                      // Get Started Button
                      // Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to CreateEvent page when pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>Event()), // Replace CreateEvent with your target page
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
