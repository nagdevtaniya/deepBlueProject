import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'date': '',
    'weather': 1, // Keep this as a default value
    'promotion': 0,
    'temperature': 0, // Keep this as a default value
    'special_event': 0,
    'day_of_week': 1, // Will be calculated
    'month': 1, // Will be calculated
  };

  bool _isLoading = false;
  DateTime? _selectedDate;

  Future<int> predictCustomers(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('http://192.168.99.172:5000/predict'), // Replace with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(formData),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['predicted_customers'];
    } else {
      throw Exception('Failed to get prediction');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calculate day_of_week and month from the date
      if (_selectedDate != null) {
        _formData['day_of_week'] = _selectedDate!.weekday; // Monday = 1, Sunday = 7
        _formData['month'] = _selectedDate!.month;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        int prediction = await predictCustomers(_formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Predicted customers: $prediction')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formData['date'] = "${picked.toLocal()}".split(' ')[0]; // Format: YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Prediction'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    icon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select a date'
                        : "${_selectedDate!.toLocal()}".split(' ')[0],
                  ),
                ),
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<int>(
                value: _formData['promotion'],
                decoration: InputDecoration(
                  labelText: 'Promotion',
                  icon: Icon(Icons.local_offer),
                ),
                items: [
                  DropdownMenuItem(child: Text('No Promotion'), value: 0),
                  DropdownMenuItem(child: Text('Promotion Active'), value: 1),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['promotion'] = value;
                  });
                },
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<int>(
                value: _formData['special_event'],
                decoration: InputDecoration(
                  labelText: 'Special Event',
                  icon: Icon(Icons.event),
                ),
                items: [
                  DropdownMenuItem(child: Text('No Special Event'), value: 0),
                  DropdownMenuItem(child: Text('Special Event Active'), value: 1),
                ],
                onChanged: (value) {
                  setState(() {
                    _formData['special_event'] = value;
                  });
                },
              ),
              SizedBox(height: 20),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Text('Predict Customers'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}