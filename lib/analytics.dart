import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'predict.dart';

class CustomerPredictionForm extends StatefulWidget {
  const CustomerPredictionForm({super.key});

  @override
  _CustomerPredictionFormState createState() => _CustomerPredictionFormState();
}

class _CustomerPredictionFormState extends State<CustomerPredictionForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool _isSpecialEvent = false;
  bool _recentPromotion = false;
  int? _numOfPeople;

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
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDate = null;
      _isSpecialEvent = false;
      _recentPromotion = false;
      _numOfPeople = null;
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Forecast Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              CheckboxListTile(
                title: Text('Special Event or Holiday'),
                value: _isSpecialEvent,
                onChanged: (bool? value) {
                  setState(() {
                    _isSpecialEvent = value!;
                  });
                },
              ),

              CheckboxListTile(
                title: Text('Recent Promotion'),
                value: _recentPromotion,
                onChanged: (bool? value) {
                  setState(() {
                    _recentPromotion = value!;
                  });
                },
              ),

              SizedBox(height: 16.0),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Number of People',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of people';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _numOfPeople = int.tryParse(value!);
                },
              ),

              SizedBox(height: 24.0),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form Submitted Successfully!')),
                    );
                    _resetForm();
                  }
                },
                child: Text('Submit'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
