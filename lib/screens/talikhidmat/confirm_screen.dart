import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/talikhidmat_provider.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  String returnCategoryInText(String category) {
    switch (category) {
      case "1":
        return "COMPLAINT";
      case "2":
        return "REQUEST FOR SERVICE";
      case "3":
        return "COMPLIMENT";
      case "4":
        return "ENQUIRY";
      default:
        return "SUGGESTION";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Note: Please verify and check the information below before submission",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(
          height: 20.0,
        ),
        const Text("TALIKHIDMAT REQUEST"),
        Text(
          returnCategoryInText(
              Provider.of<TalikhidmatProvider>(context).category),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("MESSAGE"),
        Text(
          Provider.of<TalikhidmatProvider>(context).message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("ADDRESS"),
        Text(
          Provider.of<TalikhidmatProvider>(context).address,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("LOCATION"),
        Text(
          "${Provider.of<TalikhidmatProvider>(context).latitude}, ${Provider.of<TalikhidmatProvider>(context).longitude}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        const Text("ATTACHMENTS"),
        // TODO: Attachments (eg: 5 images)
        Provider.of<TalikhidmatProvider>(context).attachments.isEmpty
            ? const Text(
                "No attachments",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            : Wrap(
                children: <Widget>[
                  ...Provider.of<TalikhidmatProvider>(context).attachments.map(
                        (e) => Container(
                          height: screenSize.height * 0.14,
                          width: screenSize.width * 0.25,
                          margin: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 8.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.5,
                            ),
                          ),
                          child: Image.network(
                            e["filePath"],
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                ],
              ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
