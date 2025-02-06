import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodDonationForm extends StatefulWidget {
  const FoodDonationForm({super.key});

  @override
  _FoodDonationFormState createState() => _FoodDonationFormState();
}

class _FoodDonationFormState extends State<FoodDonationForm> {
  String? _selectedTitle;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
        _timeController.text = selectedTime.format(context);
      });
    }
  }
  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal / Zip code is required';
    }

    // Ensure only numbers are allowed
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }

    // Check for length (5 or 6 digits)
    if (value.length != 5 && value.length != 6) {
      return 'Postal / Zip code must be 5 or 6 digits';
    }

    return null;
  }



  // Name validator to allow only alphabets
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Only alphabets are allowed';
    }
    return null;
  }

// Phone number validator to allow only numbers
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }


// Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

// Organization name validator
  String? _validateOrganizationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Organization name is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4A148C),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Food Donation Request",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Please fill in the information below.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Organization name",
                  border: OutlineInputBorder(),
                ),
                validator: _validateOrganizationName,
              ),
              SizedBox(height: 10),
              Text(
                "Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Street Address",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Street Address Line 2",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Region",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Postal / Zip Code",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Ensure numeric keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                validator: _validatePincode,
              ),



              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Country",
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: "India", child: Text("India")),
                  DropdownMenuItem(value: "United States", child: Text("United States")),
                  DropdownMenuItem(value: "Canada", child: Text("Canada")),
                  DropdownMenuItem(value: "Australia", child: Text("Australia")),
                  DropdownMenuItem(value: "United Kingdom", child: Text("United Kingdom")),
                ],
                onChanged: (value) {},
              ),
              SizedBox(height: 20),
              Text(
                "Contact Person",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedTitle,
                    items: ["Mr.", "Ms.", "Dr."]
                        .map((String value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTitle = value;
                      });
                    },
                    hint: Text("Title"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "First Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Contact Person's Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Phone",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Allow only digits
                        LengthLimitingTextInputFormatter(10),  // Limit to 10 digits
                      ],
                      validator: _validatePhone,
                    ),

                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "What type of food are you requesting?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: "Cooked food", child: Text("Cooked food")),
                  DropdownMenuItem(value: "Raw food", child: Text("Raw food")),
                ],
                onChanged: (value) {},
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Number of Consumers",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Text(
                "Preferred Date for Food Delivery",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: "Date",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () {
                            _selectDate(context); // Open the calendar picker
                          },
                        ),
                      ),
                      readOnly: true, // Prevent manual editing
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Preferred Time for Food Delivery",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: "Time",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () {
                            _selectTime(context); // Open the time picker
                          },
                        ),
                      ),
                      readOnly: true, // Prevent manual editing
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  ),
                  child: Text(
                    "Request Donation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
