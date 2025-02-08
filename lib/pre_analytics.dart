import 'package:flutter/material.dart';

import 'analytics.dart';
import 'create_event.dart';
import 'donation_form.dart';
import 'foodrequest.dart';
import 'predict.dart';
import 'volunteer_details.dart';

class BottomSheetOptions2 {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.auto_graph),
                title: Text('Data input'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerPredictionForm()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline_outlined),
                title: Text('Forecast'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PredictionForm()),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }
}
