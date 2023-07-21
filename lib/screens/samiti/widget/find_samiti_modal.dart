import 'package:flutter/material.dart';

class FindSamitiModal extends StatefulWidget {
  @override
  _FindSamitiModalState createState() => _FindSamitiModalState();
}

class _FindSamitiModalState extends State<FindSamitiModal> {
  final _formKey = GlobalKey<FormState>();
  String? samitiCode;

  void _findSamiti() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Logic to find the samiti using samitiCode goes here
      // It is dependent on your application and backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Find Samiti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Samiti code',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a code';
                }
                return null;
              },
              onSaved: (value) => samitiCode = value,
            ),
            SizedBox(height: 16.0),
            Container(
              width: double.infinity, // This makes the button stretch to fill the available space.
              child: ElevatedButton(
                onPressed: _findSamiti,
                child: Text('Find'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
