import 'package:flutter/material.dart';

class SubscriptionPriceCard extends StatefulWidget {
  const SubscriptionPriceCard({super.key});

  @override
  State<SubscriptionPriceCard> createState() => _SubscriptionPriceCardState();
}

class _SubscriptionPriceCardState extends State<SubscriptionPriceCard> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    List<Map<String, dynamic>> sampleArray = [
      {
        "month": 1,
        "monthPrice": 2.99,
      },
      {
        "month": 3,
        "monthPrice": 8.97,
      },
      {
        "month": 12,
        "monthPrice": 35.88,
      },
    ];

    return Container(
      // color: Colors.red,
      padding: EdgeInsets.all(screenSize.width * 0.03),
      child: Column(children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
            bottom: screenSize.width * 0.025,
          ),
          child: const Text(
            "Select your subscription",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          // color: Colors.yellow,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ...sampleArray.map(
                (e) {
                  int index = sampleArray.indexOf(e);
                  return GestureDetector(
                    onTap: (() {
                      print(index);
                      setState(() {
                        selectedIndex = index;
                      });
                    }),
                    child: Container(
                      width: screenSize.width * 0.3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        border: Border.all(
                          color: index == selectedIndex
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Text(
                                '${e["month"]}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Text(
                                '${e["month"] != 1 ? "months" : "month"}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "RM 2.99/month",
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Container(
                              width: screenSize.width * 0.2,
                              height: 1.0,
                              color: Colors.grey, // Color of the line
                              margin: EdgeInsets.only(
                                bottom: screenSize.height * 0.005,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: Text(
                                "RM ${e["monthPrice"]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ).toList()
            ],
          ),
        )
      ]),
    );
  }
}
