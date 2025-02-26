import 'package:flutter/material.dart';

import 'create_event.dart';
import 'donation_form.dart';
import 'foodrequest.dart';
import 'volunteer_details.dart';

class BottomSheetOptions {
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
                leading: Icon(Icons.volunteer_activism),
                title: Text('Donate'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonationForm()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline_outlined),
                title: Text('Volunteer'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VolunteerDetailsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.local_dining),
                title: Text('Receive'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FoodDonationForm2()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Organize an event'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Event()),
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
