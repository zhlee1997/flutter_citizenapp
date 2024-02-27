import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/emergency_provider.dart';

class OtherEmergencyBottomModal extends StatelessWidget {
  final VoidCallback handleProceedNext;

  OtherEmergencyBottomModal({
    required this.handleProceedNext,
    super.key,
  });

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Stack(children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 10.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: const Text(
                  "Describe your emergency to us",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Enter here to tell us more',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 10.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: const Text(
                  "Are you the one in need of help?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.red,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setOtherText(textEditingController.text);
                      // others category => 6
                      // Emergency provider => yourself: true
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setCategoryAndYourself(
                        category: 6,
                        yourself: true,
                      );
                      handleProceedNext();
                    },
                    child: const Text(
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
                  colorScheme: const ColorScheme.light(
                    primary: Colors.grey,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(),
                    onPressed: () {
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setOtherText(textEditingController.text);
                      // others category => 6
                      // Emergency provider => yourself: false
                      Provider.of<EmergencyProvider>(context, listen: false)
                          .setCategoryAndYourself(
                        category: 6,
                        yourself: false,
                      );
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
              const SizedBox(
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
      ),
    );
  }
}
