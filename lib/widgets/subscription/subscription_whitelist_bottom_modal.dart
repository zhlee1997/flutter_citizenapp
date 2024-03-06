import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SubscriptionWhitelistBottomModal extends StatefulWidget {
  final void Function() handleNavigateToChooseScreen;

  const SubscriptionWhitelistBottomModal({
    required this.handleNavigateToChooseScreen,
    super.key,
  });

  @override
  State<SubscriptionWhitelistBottomModal> createState() =>
      _SubscriptionWhitelistBottomModalState();
}

class _SubscriptionWhitelistBottomModalState
    extends State<SubscriptionWhitelistBottomModal> {
  String _url = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url = "assets/disclaimer/security_disclaimer.md";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
        // Define padding for the container.
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        // Create a Wrap widget to display the sheet contents.
        child: Wrap(
          spacing: 60, // Add spacing between the child widgets.
          children: <Widget>[
            // Add a container with height to create some space.
            Container(height: 10),
            // Add a text widget with a title for the sheet.
            Text(
              "Whitelisted Access",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Container(height: 10), // Add some more space.
            // Add a text widget with a long description for the sheet.
            RichText(
                text: TextSpan(
              text:
                  "You are whitelisted and entitled for free subscription service. By proceeding to access the service, you agree to the ",
              style: TextStyle(
                color: Colors.grey[600], // Set the text color.
                fontSize: 16.0,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'Security Disclaimer',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = (() {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: FutureBuilder(
                                      future: rootBundle.loadString(_url),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.hasData) {
                                          return Markdown(
                                              data: snapshot.data ?? "");
                                        }

                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ));
                      }))
              ],
            )),
            Container(
                height: screenSize.height * 0.035), // Add some more space.
            // Add a row widget to display buttons for closing and reading more.
            SizedBox(
              width: screenSize.width * 0.9,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ), // Set the button background color.
                onPressed: () {
                  Navigator.pop(context); // Close the sheet.
                  widget.handleNavigateToChooseScreen();
                },
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ), // Add the button text.
              ),
            )
          ],
        ));
  }
}
