import 'package:flutter/material.dart';

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
                  Navigator.pop(context); // Handle your pin action here
                  // Additional logic for "Pin" can be added here
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline_outlined),
                title: Text('Volunteer'),
                onTap: () {
                  Navigator.pop(context); // Handle collage action
                  // Additional logic for "Collage" can be added here
                },
              ),
              ListTile(
                leading: Icon(Icons.local_dining),
                title: Text('Receive'),
                onTap: () {
                  Navigator.pop(context); // Handle board action
                  // Additional logic for "Board" can be added here
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Organize an event'),
                onTap: () {
                  Navigator.pop(context); // Handle board action
                  // Additional logic for "Board" can be added here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
