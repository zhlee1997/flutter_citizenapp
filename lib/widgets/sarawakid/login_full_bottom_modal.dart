import 'package:flutter/material.dart';

import '../../screens/sarawakid/sarawakid_screen.dart';

class LoginFullBottomModal extends StatelessWidget {
  const LoginFullBottomModal({super.key});

  void handleNavigateSarawakIDScreen(BuildContext context) =>
      Navigator.of(context).pushNamed(SarawakIDScreen.routeName);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.clear_outlined,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Image.asset(
                "assets/images/icon/app_logo.png",
                width: screenSize.width * 0.75,
                height: screenSize.width * 0.75,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.75,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey There,\nWelcome to CitizenApp",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  Text("Login to your account to continue")
                ],
              ),
            ),
            SizedBox(
              height: screenSize.height * 0.075,
            ),
            Container(
              width: screenSize.width * 0.75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.15, 0.55],
                  colors: [
                    Theme.of(context).colorScheme.error,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {},
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/icon/sarawakid_logo.png",
                      width: screenSize.width * 0.1,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "Sign Up with SarawakID",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: screenSize.width * 0.8,
              child: Divider(),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Already have an account?",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: screenSize.width * 0.75,
              height: screenSize.width * 0.125,
              child: OutlinedButton(
                onPressed: () => handleNavigateSarawakIDScreen(context),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/icon/sarawakid_logo.png",
                      width: screenSize.width * 0.1,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text("Sign In with SarawakID")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
