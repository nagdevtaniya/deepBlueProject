import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MaterialApp(home: EventPage()));
}

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
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

  void _createEvent() async {
    if (_selectedEvent != null && _selectedDate != null && _selectedTime != null) {
      Map<String, dynamic> eventData = {
        'eventTitle': _selectedEvent,
        'date': _formatDate(_selectedDate!),
        'time': _selectedTime!.format(context),
        'description': _descriptionController.text,
        'place': _placeController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        // Attempt to add event data to Firestore
        await FirebaseFirestore.instance.collection('events').add(eventData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Event Created Successfully!")),
        );

        // Clear form fields after successful creation
        setState(() {
          _selectedEvent = null;
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
          _placeController.clear();
        });
      } catch (error) {
        // If an error occurs, show it in a SnackBar
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
              child: Text(_selectedDate == null
                  ? 'Pick Date'
                  : _formatDate(_selectedDate!)),
            ),
            SizedBox(height: 16),
            Text("Select Time"),
            ElevatedButton(
              onPressed: _pickTime,
              child: Text(_selectedTime == null
                  ? 'Pick Time'
                  : _selectedTime!.format(context)),
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
    return Scaffold(
      appBar: AppBar(title: Text("Events List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
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
              return ListTile(
                title: Text(event['eventTitle'] ?? 'No Title'),
                subtitle: Text(
                    "${event['date'] ?? 'No Date'} at ${event['time'] ?? 'No Time'}"),
              );
            },
          );
        },
      ),
    );
  }
}
