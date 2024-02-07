import 'package:flutter/material.dart';

class OtherEmergencyBottomModal extends StatelessWidget {
  final VoidCallback handleProceedNext;

  const OtherEmergencyBottomModal({
    required this.handleProceedNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Stack(children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                top: 20.0,
                bottom: 10.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Text(
                "Describe your emergency to us",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter here to tell us more',
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                top: 20.0,
                bottom: 10.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Text(
                "Are you the one in need of help?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.red,
                ),
              ),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    handleProceedNext();
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.grey,
                ),
              ),
              child: Container(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(),
                  onPressed: () {
                    handleProceedNext();
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 60,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
