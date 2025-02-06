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
    'weather': 1,
    'promotion': 0,
    'temperature': 0,
    'special_event': 0,
    'day_of_week': 1,
    'month': 1,
  };

  Future<int> predictCustomers(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('http://192.168.162.203:5000/predict'),// Replace with this
      // Use your actual backend URL
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
      try {
        int prediction = await predictCustomers(_formData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Predicted customers: $prediction')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onSaved: (value) => _formData['date'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Weather (0 for bad, 1 for good)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['weather'] = int.parse(value ?? '0'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Promotion (0 or 1)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['promotion'] = int.parse(value ?? '0'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Temperature'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['temperature'] = int.parse(value ?? '0'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Special Event (0 or 1)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['special_event'] = int.parse(value ?? '0'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Day of the Week (1 for Monday, etc.)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['day_of_week'] = int.parse(value ?? '0'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Month (1-12)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _formData['month'] = int.parse(value ?? '0'),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Predict Customers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
