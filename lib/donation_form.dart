import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'recipient_details.dart';
class DonationForm extends StatefulWidget {
  const DonationForm({super.key});

  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _foodDescriptionController = TextEditingController();
  final TextEditingController _newLocationController = TextEditingController();
  final List<Map<String, String>> _items = [];
  String _pickupLocation = "Add another location";
  bool _showNewLocationField = true;
  String _selectedUnit = "kg"; // Default unit

  void _addItem() {
    if (_itemController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      setState(() {
        _items.add({
          "name": _itemController.text,
          "amount": "${_amountController.text} $_selectedUnit",
        });
        _itemController.clear();
        _amountController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Donation Information'),
        backgroundColor: const Color(0xFF4A148C), // Purple
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFFFEBEE)], // Light purple to pink
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>RecipientDetailsPage()), // Replace CreateEvent with your target page
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A148C), // Purple
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Notify Recipient', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Food description:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _foodDescriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter food description',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Estimated amount of food:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _itemController,
                            decoration: InputDecoration(
                              hintText: 'New Item',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedUnit,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                            });
                          },
                          items: <String>['kg', 'lbs', 'pcs']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF880E4F), // Dark Pink
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Items List:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.circle, size: 8, color: Color(0xFF4A148C)),
                          title: Text("${_items[index]['name']} - ${_items[index]['amount']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _removeItem(index);
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Pick up Location:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        RadioListTile(
                          title: const Text('My Location'),
                          value: "My Location",
                          groupValue: _pickupLocation,
                          onChanged: (value) {
                            setState(() {
                              _pickupLocation = value as String;
                              _showNewLocationField = false;
                            });
                          },
                        ),
                        RadioListTile(
                          title: const Text('Add another location'),
                          value: "Add another location",
                          groupValue: _pickupLocation,
                          onChanged: (value) {
                            setState(() {
                              _pickupLocation = value as String;
                              _showNewLocationField = true;
                            });
                          },
                        ),
                        if (_showNewLocationField)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                            child: TextField(
                              controller: _newLocationController,
                              decoration: const InputDecoration(
                                hintText: 'Enter new location',
                                border: OutlineInputBorder(),
                              ),
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
      ),
    );
  }
}
