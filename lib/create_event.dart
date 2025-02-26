import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCy753J-EPzfgaGZLjumgJgam-C8kRYFn4",
      authDomain: "deep-blue-project-b05a1.firebaseapp.com",
      projectId: "deep-blue-project-b05a1",
      storageBucket: "deep-blue-project-b05a1.appspot.com",
      messagingSenderId: "842871110807",
      appId: "1:842871110807:android:498dd4494a00d0e312fdd2",
    ),
  );
  runApp(MaterialApp(home: Event()));
}

class Event extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<Event> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedEvent;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  final List<String> _eventTypes = [
    'Birthday Party',
    'Wedding',
    'Conference',
    'Meeting',
    'Anniversary',
    'Others',
  ];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<String> createGoogleForm(String eventTitle, String eventDate, String eventTime, String eventPlace) async {
    final url = Uri.parse('https://script.google.com/macros/s/AKfycbxBnjCrJl1iKayI0WMOHWt9zfkhj56MqujAjKB0JsdYosOc8sfMKs2v4DYxnC_ftyLl1w/exec');
    final response = await http.post(
      url,
      body: {
        'eventTitle': eventTitle,
        'eventDate': eventDate,
        'eventTime': eventTime,
        'eventPlace': eventPlace,
      },
    );

    if (response.statusCode == 200) {
      return response.body; // Returns the form URL
    } else {
      throw Exception('Failed to create Google Form');
    }
  }

  Future<void> _createEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    if (_selectedEvent != null && _selectedDate != null && _selectedTime != null) {
      final googleFormLink = await createGoogleForm(
        _selectedEvent!,
        _formatDate(_selectedDate!),
        _selectedTime!.format(context),
        _placeController.text,
      );

      Map<String, dynamic> eventData = {
        'eventTitle': _selectedEvent,
        'date': _formatDate(_selectedDate!),
        'time': _selectedTime!.format(context),
        'description': _descriptionController.text,
        'place': _placeController.text,
        'googleFormLink': googleFormLink,
        'totalGuests': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .add(eventData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Event Created Successfully! Google Form Link: $googleFormLink")),
        );

        setState(() {
          _selectedEvent = null;
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
          _placeController.clear();
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create event: $error")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the fields!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Event Type"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedEvent,
              items: _eventTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEvent = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text("Select Date"),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(_selectedDate == null ? 'Pick Date' : _formatDate(_selectedDate!)),
            ),
            SizedBox(height: 16),
            Text("Select Time"),
            ElevatedButton(
              onPressed: _pickTime,
              child: Text(_selectedTime == null ? 'Pick Time' : _selectedTime!.format(context)),
            ),
            SizedBox(height: 16),
            Text("Event Description"),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(hintText: 'Enter event description'),
            ),
            SizedBox(height: 16),
            Text("Event Place"),
            TextField(
              controller: _placeController,
              decoration: InputDecoration(hintText: 'Enter event place'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _createEvent,
              child: Text("Create Event"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListPage()),
                );
              },
              child: Text("View Events List"),
            ),
          ],
        ),
      ),
    );
  }
}

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text("User not logged in!"));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Events List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No events available."));
          }
          var events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              var event = events[index].data() as Map<String, dynamic>;
              var eventId = events[index].id;
              var googleFormLink = event['googleFormLink'];
              return ListTile(
                title: Text(event['eventTitle'] ?? 'No Title'),
                subtitle: Text(
                    "${event['date'] ?? 'No Date'} at ${event['time'] ?? 'No Time'}\nTotal Guests: ${event['totalGuests']}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailPage(eventId: eventId, userId: user.uid),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EventDetailPage extends StatelessWidget {
  final String eventId;
  final String userId;

  EventDetailPage({required this.eventId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Event not found."));
          }

          // Force Firestore to fetch fresh data
          snapshot.data!.reference.get(GetOptions(source: Source.server)).then((doc) {
            print("Fresh Data from Server: ${doc.data()}");
          });

          var event = snapshot.data!.data() as Map<String, dynamic>;
          print("Event Data Updated: $event"); // Log the updated event data

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Event Title: ${event['eventTitle'] ?? 'No Title'}"),
                Text("Date: ${event['date'] ?? 'No Date'}"),
                Text("Time: ${event['time'] ?? 'No Time'}"),
                Text("Description: ${event['description'] ?? 'No Description'}"),
                Text("Place: ${event['place'] ?? 'No Place'}"),
                Text("Total Guests: ${event['totalGuests'] ?? '0'}"), // Ensure this is displayed
                ElevatedButton(
                  onPressed: () async {
                    String url = event['googleFormLink'];
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Could not launch the Google Form link: $url")),
                      );
                    }
                  },
                  child: Text("RSVP via Google Form"),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share('Join my event: ${event['googleFormLink']}');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}