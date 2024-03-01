import 'package:flutter/material.dart';

class SubscriptionListScreen extends StatelessWidget {
  static const String routeName = "subscription-list-screen";

  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("List Display"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(
          bottom: 20.0,
        ),
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: ((context, index) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: screenSize.height * 0.035,
                color: Colors.blueGrey.shade800,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      "CCTV ${index + 1}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: screenSize.height * 0.3,
                color: Colors.red,
                child: Stack(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/pictures/kuching_city.jpeg",
                      width: double.infinity,
                      height: screenSize.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: screenSize.width * 0.5,
                      color: Colors.black,
                      child: Text(
                        "02/03/2024 12:17:12 AM",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
