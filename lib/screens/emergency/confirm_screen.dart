import 'package:flutter/material.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Note: Please verify and check the information below before submission",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text("NAME"),
        Text(
          "Steven Bong",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text("SARAWAK ID"),
        Text(
          "S127354",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text("ADDRESS"),
        Text(
          "26, Jalan SS 2/103, SS 2, 47300 Petaling Jaya, Selangor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text("LOCATION"),
        Text(
          "3.126971, 101.625321",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
