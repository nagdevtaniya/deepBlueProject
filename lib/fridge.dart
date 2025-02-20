import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'composting chatbot.dart';
import 'recipe chatbot.dart'; // Assuming this package is used
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

void listenForUser() {
  auth.authStateChanges().listen((User? user) {
    if (user != null) {
      checkExpiringItems(user.uid);
    }
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> notifyUser(List<Map<String, dynamic>> expiringItems) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  int notificationId = 0; // Initialize a unique ID counter

  for (final item in expiringItems) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationId, // Use the unique ID for each notification
      'Expiry Alert',
      'Item "${item['name']}" expires in ${item['daysLeft']} days.',
      platformChannelSpecifics,
    );

    notificationId++; // Increment the ID for the next notification
  }
}

Future<void> checkExpiringItems(String userId) async {
  final now = DateTime.now();
  final sevenDaysFromNow = now.add(Duration(days: 7));

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fridgeItems')
        .get();

    final expiringItems = <Map<String, dynamic>>[];

    for (final doc in querySnapshot.docs) {
      final item = doc.data();
      final expiryDate = (item['expiryDate'] as Timestamp).toDate();

      if (expiryDate.isBefore(sevenDaysFromNow)) {
        final daysLeft = expiryDate.difference(now).inDays;
        expiringItems.add({
          'name': item['name'],
          'daysLeft': daysLeft,
        });
      }
    }

    // Only notify if there are expiring items
    if (expiringItems.isNotEmpty) {
      await notifyUser(expiringItems);
    }
  } catch (error) {
    print('Error fetching fridge items: $error');
  }
}


class FoodItem {
  final int id;
  final String name;
  final String location;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final int quantity;


  FoodItem({
    required this.id,
    required this.name,
    required this.location,
    required this.purchaseDate,
    required this.expiryDate,
    required this.quantity,
  });
}


class MyFridge extends StatefulWidget {
  const MyFridge({super.key});


  @override
  _MyFridgeState createState() => _MyFridgeState();
}


class _MyFridgeState extends State<MyFridge> {
  List<FoodItem> items = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();


  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    fetchItems();
    listenForUser(); // Fetch items when the widget is initialized
  }
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  Future<void> fetchItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userID = user.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('fridgeItems')
          .get();

      final List<FoodItem> fetchedItems = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final purchaseDate = (data['purchaseDate'] as Timestamp).toDate(); // Convert to DateTime
        final expiryDate = (data['expiryDate'] as Timestamp).toDate(); // Convert to DateTime

        fetchedItems.add(FoodItem(
          id: int.parse(doc.id.hashCode.toString()),
          name: data['name'],
          location: data['location'],
          purchaseDate: purchaseDate,
          expiryDate: expiryDate,
          quantity: data['quantity'],
        ));
      }

      setState(() {
        items = fetchedItems;
      });
    }
  }

  void _addItem(FoodItem item) async {
    setState(() {
      items.add(item);
      _listKey.currentState?.insertItem(items.length - 1);
    });
    await fetchItems(); // Refresh the list
  }


  void _deleteItem(int index) async {
    final removedItem = items[index];
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userID = user.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('fridgeItems')
          .where('name', isEqualTo: removedItem.name) // Match by name
          .where('purchaseDate', isEqualTo: Timestamp.fromDate(removedItem.purchaseDate)) // Ensure uniqueness
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      _listKey.currentState?.removeItem(
        index,
            (context, animation) => _buildItem(removedItem, index, animation),
      );

      setState(() {
        items.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${removedItem.name} removed")),
      );
    }
  }


  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(onSave: _addItem),
      ),
    );
  }


  Widget _buildItem(FoodItem item, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text('Location: ${item.location}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Purchase Date: ${DateFormat('MMM dd, yyyy').format(item.purchaseDate.toLocal())}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Expiry Date: ${DateFormat('MMM dd, yyyy').format(item.expiryDate.toLocal())}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              Text('Qty: ${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Fridge')),
      body: items.isEmpty
          ? const Center(child: Text('Pretty empty here!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)))
          : AnimatedList(
        key: _listKey,
        initialItemCount: items.length,
        itemBuilder: (context, index, animation) {
          return Dismissible(
            key: Key(items[index].name), // Unique key
            direction: DismissDirection.endToStart, // Swipe left to delete
            onDismissed: (_) => _deleteItem(index),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildItem(items[index], index, animation),
          );
        },
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // SpeedDial button positioned at bottom right with some margin
          Positioned(
            bottom: 16.0, // Adjust for margin
            right: 16.0, // Adjust for margin
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Colors.green,
              direction: SpeedDialDirection.up,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'Manually Add Item',
                  onTap: () {
                    _navigateToAddItem();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.camera),
                  label: 'Scan with Camera',
                  onTap: () {
                    // Implement camera scan
                  },
                ),
              ],
            ),
          ),
          // First button above SpeedDial with some margin
          Positioned(
            bottom: 155.0, // Adjust based on SpeedDial margin and FAB size
            right: 16.0,  // Adjust for margin
            child: FloatingActionButton(
              onPressed: () {
                // Action for first button
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipeChatbot()),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.fastfood_rounded),
            ),
          ),
          // Second button above SpeedDial with some margin
          Positioned(
            bottom: 85.0, // Adjust based on FAB sizes and desired spacing
            right: 16.0,  // Adjust for margin
            child: FloatingActionButton(
              onPressed: () {
                print('CompostingChatbot');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompostingChatbot()),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.eco),
            ),
          ),
        ],
      ),
    );
  }
}


class AddItemScreen extends StatefulWidget {
  final Function(FoodItem) onSave;


  const AddItemScreen({super.key, required this.onSave});


  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}


class _AddItemScreenState extends State<AddItemScreen> {
  int _idCounter = 0;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  String location = 'Fridge';
  DateTime purchaseDate = DateTime.now();
  DateTime expiryDate = DateTime.now().add(Duration(days: 30));
  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');


  void _selectDate(BuildContext context, bool isPurchaseDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate ? purchaseDate : expiryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isPurchaseDate) {
          purchaseDate = pickedDate;
        } else {
          expiryDate = pickedDate;
        }
      });
    }
  }


  Future<void> _saveItem() async {
    if (nameController.text.isNotEmpty && int.tryParse(quantityController.text) != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userID = user.uid;
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('fridgeItems')
            .doc(); // Auto-generate unique ID

        // Convert DateTime to Firestore Timestamp
        final purchaseTimestamp = Timestamp.fromDate(purchaseDate);
        final expiryTimestamp = Timestamp.fromDate(expiryDate);

        final item = FoodItem(
          id: int.parse(docRef.id.hashCode.toString()), // Convert Firestore ID to int
          name: nameController.text,
          location: location,
          purchaseDate: purchaseDate,
          expiryDate: expiryDate,
          quantity: int.parse(quantityController.text),
        );

        // Save to Firestore with Timestamp
        await docRef.set({
          'name': item.name,
          'location': item.location,
          'purchaseDate': purchaseTimestamp, // Save as Timestamp
          'expiryDate': expiryTimestamp, // Save as Timestamp
          'quantity': item.quantity,
          'userId': userID,
        });

        widget.onSave(item);

        // Check if the item being added is near expiry
        final now = DateTime.now();
        final sevenDaysFromNow = now.add(Duration(days: 7));

        if (expiryDate.isBefore(sevenDaysFromNow)) {
          // Only check for expiring items if the new item is near expiry
          await checkExpiringItems(userID);
        }

        Navigator.pop(context);
      } else {
        print("User is not authenticated.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/img.png'),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // Add image picker logic here
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Food name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: location,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              items: ['Fridge', 'Freezer', 'Pantry'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  location = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Purchase Date: ${dateFormatter.format(purchaseDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text('Expiry Date: ${dateFormatter.format(expiryDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveItem,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}