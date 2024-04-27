import 'package:flutter/material.dart';
import 'package:flutter_citizenapp/providers/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionFrequencyBottomModal extends StatefulWidget {
  final VoidCallback handleProceedNow;

  const SubscriptionFrequencyBottomModal(
      {required this.handleProceedNow, super.key});

  @override
  State<SubscriptionFrequencyBottomModal> createState() =>
      _SubscriptionFrequencyBottomModalState();
}

class _SubscriptionFrequencyBottomModalState
    extends State<SubscriptionFrequencyBottomModal> {
  int freq = -1;

  Future<int> queryFrequencyLimitLeft() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt("frequencyLimitLeft") ?? -1;
    return num;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        freq = Provider.of<SubscriptionProvider>(context, listen: false)
            .frequencyLimitLeft;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Access left per day",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text("${freq} times"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "You have limited access per day for the subscription services. Are you sure to proceed?"),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Later",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: widget.handleProceedNow,
                  child: Text(
                    "Proceed Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
