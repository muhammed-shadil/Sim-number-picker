import 'package:flutter/material.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PhoneNumberAuthScreen(),
    );
  }
}

class PhoneNumberAuthScreen extends StatefulWidget {
  @override
  _PhoneNumberAuthScreenState createState() => _PhoneNumberAuthScreenState();
}

class _PhoneNumberAuthScreenState extends State<PhoneNumberAuthScreen> {
  List<String> simCards = [];

  @override
  void initState() {
    super.initState();
    _getSimNumbers();
  }

  Future<void> _getSimNumbers() async {
    var permissionStatus = await Permission.phone.request();
    if (permissionStatus.isGranted) {
      try {
        String? mobileNumber = await MobileNumber.mobileNumber;
        List<SimCard>? simCardsList = await MobileNumber.getSimCards;
        setState(() {
          simCards = (simCardsList ?? [])
              .map((simCard) => simCard.number ?? "Unknown")
              .toList();
        });
      } catch (e) {
        print("Failed to get mobile number: $e");
      }
    } else {
      print("Phone permission not granted.");
    }
  }

  void _showSimPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Phone Number'),
          content: simCards.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: simCards.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(simCards[index]),
                      onTap: () {
                        Navigator.pop(context, simCards[index]);
                      },
                    );
                  },
                )
              : const Text("No SIM cards found."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((selectedNumber) {
      if (selectedNumber != null) {
        print("Selected phone number: $selectedNumber");
        setState(() {
          _phoneController.text = selectedNumber;
        });
      }
    });
  }

  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Number Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: _showSimPicker, // Show SIM picker dialog
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Proceed with authentication or next step
                print("Phone Number: ${_phoneController.text}");
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

// class SimCard {
//   String? number; // Add the 'number' field
// }
