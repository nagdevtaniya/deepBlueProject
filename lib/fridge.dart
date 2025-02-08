
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'composting chatbot.dart';
import 'recipe chatbot.dart'; // Assuming this package is used

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

  void _addItem(FoodItem item) {
    setState(() {
      items.add(item);
      _listKey.currentState?.insertItem(items.length - 1); // Animate addition
    });
  }

  void _deleteItem(int index) {
    final removedItem = items[index];
    items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildItem(removedItem, index, animation),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${removedItem.name} dismissed")));
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
            return GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) _deleteItem(index); // Swipe left to delete
              },
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
        )


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

  void _saveItem() {
    if (nameController.text.isNotEmpty && int.tryParse(quantityController.text) != null) {
      final item = FoodItem(
        id: _idCounter++,
        name: nameController.text,
        location: location,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        quantity: int.parse(quantityController.text),
      );
      widget.onSave(item);
      Navigator.pop(context);
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

