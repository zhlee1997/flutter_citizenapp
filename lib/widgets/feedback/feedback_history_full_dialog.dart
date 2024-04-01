import 'package:flutter/material.dart';

import '../../services/feedback_services.dart';
import '../../models/feedback_model.dart';

class FeedbackHistoryFullDialog extends StatefulWidget {
  const FeedbackHistoryFullDialog({super.key});

  @override
  State<FeedbackHistoryFullDialog> createState() =>
      _FeedbackHistoryFullDialogState();
}

class _FeedbackHistoryFullDialogState extends State<FeedbackHistoryFullDialog> {
  List<FeedbackModel> _feedbacks = [];
  late ScrollController _scrollController;
  int _page = 1;
  bool _noMoreData = false;

  Future<void> getFeedbacks(int page) async {
    try {
      var response = await FeedbackServices().queryUserFeedbacks('$page');
      if (response["status"] == "200") {
        var data = response['data']['list'] as List;
        setState(() {
          if (data.length < 20) {
            _noMoreData = true;
          }

          if (page == 1) {
            _feedbacks = data.map((e) => FeedbackModel.fromJson(e)).toList();
          } else {
            _feedbacks
                .addAll(data.map((e) => FeedbackModel.fromJson(e)).toList());
          }
        });
      }
    } catch (e) {
      print("getFeedbacks error: ${e.toString()}");
    }
  }

  String handleImprovements({
    required int billPayment,
    required int busSchedule,
    required int emergencyButton,
    required int liveVideo,
    required int talikhidmat,
    required int tourismInformation,
    required int trafficImages,
    required int others,
  }) {
    List<String> tempArr = [];
    if (talikhidmat == 1) tempArr.add("Talikhidmat");
    if (emergencyButton == 1) tempArr.add("Emergency Button");
    if (trafficImages == 1) tempArr.add("Traffic Images");
    if (tourismInformation == 1) tempArr.add("Tourism Information");
    if (liveVideo == 1) tempArr.add("Live Video");
    if (billPayment == 1) tempArr.add("Bill Payment");
    if (busSchedule == 1) tempArr.add("Bus Schedule");
    if (others == 1) tempArr.add("Others");

    if (tempArr.isNotEmpty) {
      return "Improvements: ${tempArr.join(", ")}";
    } else {
      return "No Improvements";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          var maxScroll = _scrollController.position.maxScrollExtent;
          var pixels = _scrollController.position.pixels;
          if (maxScroll == pixels && !_noMoreData) {
            _page++;
            getFeedbacks(_page);
          }
        });
      });
    getFeedbacks(_page);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Feedback History",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_outlined),
                )
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
                child: ListView.separated(
              controller: _scrollController,
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          _feedbacks[index].starLevel.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        const Text(
                          "\u00B7",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          _feedbacks[index].createTime,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Text(
                      _feedbacks[index].remarks ?? "No remarks",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      handleImprovements(
                        billPayment: _feedbacks[index].billPayment,
                        busSchedule: _feedbacks[index].busSchedule,
                        emergencyButton: _feedbacks[index].emergencyButton,
                        liveVideo: _feedbacks[index].liveVideo,
                        talikhidmat: _feedbacks[index].talikhidmat,
                        tourismInformation:
                            _feedbacks[index].tourismInformation,
                        trafficImages: _feedbacks[index].trafficImages,
                        others: _feedbacks[index].others,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w300),
                    )
                  ],
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
