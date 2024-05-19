import 'package:flutter/material.dart';

class SubscriptionPriceCard extends StatefulWidget {
  final double oneMonthPrice;
  final double threeMonthPrice;
  final double twelveMonthPrice;
  final Function(int, double) handleSelectPackage;

  const SubscriptionPriceCard({
    required this.oneMonthPrice,
    required this.threeMonthPrice,
    required this.twelveMonthPrice,
    required this.handleSelectPackage,
    super.key,
  });

  @override
  State<SubscriptionPriceCard> createState() => _SubscriptionPriceCardState();
}

class _SubscriptionPriceCardState extends State<SubscriptionPriceCard> {
  int selectedIndex = 0;
  late List<Map<String, dynamic>> packageArray;

  String formatPrice(double price) {
    String roundedNumber = price.toStringAsFixed(2);
    return roundedNumber;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    packageArray = [
      {
        "days": 30,
        "monthPrice": double.parse(widget.oneMonthPrice.toStringAsFixed(2)),
      },
      {
        "days": 90,
        "monthPrice": double.parse(widget.threeMonthPrice.toStringAsFixed(2)),
      },
      {
        "days": 365,
        "monthPrice": double.parse(widget.twelveMonthPrice.toStringAsFixed(2)),
      },
    ];

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.03),
      child: Column(children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
            bottom: screenSize.width * 0.03,
          ),
          child: const Text(
            "Select your package",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ...packageArray.map(
              (e) {
                int index = packageArray.indexOf(e);
                return GestureDetector(
                  onTap: (() {
                    setState(() {
                      selectedIndex = index;
                      widget.handleSelectPackage(
                          index, packageArray[index]["monthPrice"]);
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
                            margin: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '${e["days"]}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text(
                              'Days',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          Text(index == 0
                              ? "Package A"
                              : index == 1
                                  ? "Package B"
                                  : "Package C"),
                          // Text(
                          //   index == 0
                          //       ? "RM ${e["monthPrice"]}/month"
                          //       : index == 1
                          //           ? "RM ${formatPrice(e["monthPrice"] / 3)}/month"
                          //           : "RM ${formatPrice(e["monthPrice"] / 12)}/month",
                          //   style: const TextStyle(
                          //     fontSize: 12.0,
                          //   ),
                          // ),
                          const SizedBox(
                            height: 25.0,
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
                            margin: const EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text(
                              "RM ${e["monthPrice"]}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
            ),
          ],
        ),
      ]),
    );
  }
}
