import 'package:flutter/material.dart';

class ServicesBottomNavScreen extends StatelessWidget {
  static const String routeName = 'servcies-bottom-nav-screen';

  const ServicesBottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 0.7 / 1,
          ),
          children: <Widget>[
            GestureDetector(
              onTap: () {
                print("Talikhidmat pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/pictures/talikhidmat_image.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.feedback_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Talikhidmat",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Emergency button pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: AssetImage("assets/images/pictures/sos_image.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.15,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.sos_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Emergency Button",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Premium Subscription pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/pictures/subscription_image.jpg"),
                        fit: BoxFit.cover,
                        opacity: 0.2,
                      )),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.subscriptions_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Premium Subscription",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Traffic images pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/pictures/traffic_image.jpg"),
                        fit: BoxFit.cover,
                        opacity: 0.2,
                      )),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.traffic_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Traffic Images",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Bill Payment pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/pictures/payment_image.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.wallet_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Bill Payment",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Tourism News");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/pictures/tourism_image.jpg"),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      )),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.luggage_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Tourism News",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Bus Schedule pressed");
              },
              child: Card(
                elevation: 5.0,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image:
                            AssetImage("assets/images/pictures/bus_image.jpg"),
                        fit: BoxFit.cover,
                        opacity: 0.2,
                      )),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 35.0,
                        ),
                        child: Icon(
                          Icons.bus_alert_outlined,
                          size: 50.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Bus Schedule",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
