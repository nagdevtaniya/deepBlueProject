import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  Future<int> predictCustomers(Map<String, dynamic> formData) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/predict'),  // Replace with actual URL
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
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Day of the week'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a day';
                  }
                  return null;
                },
                onSaved: (value) => _formData['day'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Special event? (yes/no)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter yes or no';
                  }
                  return null;
                },
                onSaved: (value) => _formData['special_event'] = value,
              ),
              // Add more fields as needed
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
