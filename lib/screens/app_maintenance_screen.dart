import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppMaintenanceScreen extends StatelessWidget {
  static const String routeName = "app-maintenance-screen";

  const AppMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/svg/undraw_bug_fixing.svg",
                width: screenSize.width * 0.4,
                height: screenSize.width * 0.4,
                semanticsLabel: 'Talikhidmat Onboarding Logo',
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              Text(
                "App Under Maintenance",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              SizedBox(
                width: screenSize.width * 0.8,
                child: Text(
                  "Sorry for the inconvenience caused. The app will be resumed soon. We appreciate your pateience.",
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.05,
              ),
              if (Platform.isAndroid)
                SizedBox(
                  width: screenSize.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text("Close the app"),
                  ),
                ),
              if (Platform.isIOS)
                Container(
                  padding: const EdgeInsets.only(bottom: 1.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.0,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ),
                  child: Text('You may try again later.'),
                )
            ],
          ),
        ),
      ),
    );
  }
}
