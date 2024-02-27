import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../../services/feedback_services.dart';
import '../../utils/global_dialog_helper.dart';

class SendFeedbackScreen extends StatefulWidget {
  static const String routeName = 'send-feedback-screen';

  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  late double _feedbackValue;

  final FeedbackServices _feedbackServices = FeedbackServices();
  final GlobalDialogHelper _globalDialogHelper = GlobalDialogHelper();

  void _handleFeedbackWord(double rating, double customRating) {
    if ((rating >= 4.5) && (rating <= 5.0)) {
      setState(() {
        _feedbackValue = 5.0;
      });
    } else if ((rating >= 3.5) && (rating < 4.5)) {
      setState(() {
        _feedbackValue = 4.0;
      });
    } else if ((rating >= 2.5) && (rating < 3.5)) {
      setState(() {
        _feedbackValue = 3.0;
      });
    } else if ((rating >= 1.5) && (rating < 2.5)) {
      setState(() {
        _feedbackValue = 2.0;
      });
    } else {
      setState(() {
        _feedbackValue = 1.0;
      });
    }
    print("_feedbackValue $_feedbackValue");
  }

  @override
  void initState() {
    _feedbackValue = 5.0;
    super.initState();
  }

  final FocusNode _focusNode = FocusNode();
  // final FocusNode _otherFocusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  // final TextEditingController _otherTextEditingController =
  //     TextEditingController();

  String _handleGridText(int index) {
    switch (index) {
      case 0:
        return "Talikhidmat";
      case 1:
        return "Emergency Button";
      case 2:
        return "Traffic Images";
      case 3:
        return "Tourism Information";
      case 4:
        return "Live Video";
      case 5:
        return "Bill Payment";
      case 6:
        return "Bus Schedule";
      default:
        return "Others";
    }
  }

  List<int> selectedIndexes = [];

  void _handleIndex(int idx) {
    if (selectedIndexes.contains(idx)) {
      setState(() {
        selectedIndexes.remove(idx);
      });
    } else {
      setState(() {
        selectedIndexes.add(idx);
      });
    }
  }

  Future<void> _showDoneDialog() async {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ClipRect(
                  child: Align(
                    heightFactor: 0.6,
                    child: Lottie.asset(
                      'assets/animations/lottie_done.json',
                      width: screenSize.width * 0.5,
                      height: screenSize.width * 0.5,
                      repeat: false,
                    ),
                  ),
                ),
                const Text('Thank you for your feedback'),
                const SizedBox(height: 16),
                SizedBox(
                  width: screenSize.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(context).pop();
                      // Pop the current screen
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  // TODO: API POST => rate, indexes, text
  Future<void> _handleSubmitFeedback(String text) async {
    try {
      // Hide the keyboard
      _focusNode.unfocus();
      // other => showModalBottomSheet
      // if (selectedIndexes.contains(7)) {
      //   await showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     builder: (_) {
      //       return Padding(
      //         padding: EdgeInsets.only(
      //           bottom: MediaQuery.of(context).viewInsets.bottom,
      //         ),
      //         child: Container(
      //           padding: const EdgeInsets.all(10.0),
      //           width: double.infinity,
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: <Widget>[
      //               Container(
      //                 padding: const EdgeInsets.symmetric(vertical: 10.0),
      //                 child: Text(
      //                   'Let us know the "Others"',
      //                   style: Theme.of(context).textTheme.titleLarge,
      //                 ),
      //               ),
      //               Container(
      //                 margin: const EdgeInsets.symmetric(vertical: 10.0),
      //                 child: TextField(
      //                   controller: _otherTextEditingController,
      //                   maxLines: 3,
      //                   keyboardType: TextInputType.multiline,
      //                   textInputAction: TextInputAction.done,
      //                   focusNode: _otherFocusNode,
      //                   // onChanged callback will be called whenever the user types in the text field
      //                   onChanged: (String value) {
      //                     print("Typed: $value");
      //                   },
      //                   style: const TextStyle(
      //                     fontSize: 15.0,
      //                   ),
      //                   decoration: const InputDecoration(
      //                     hintText:
      //                         'Briefly describe about "Others" so we can understand it better',
      //                     border: OutlineInputBorder(),
      //                   ),
      //                 ),
      //               ),
      //               const Divider(),
      //               TextButton.icon(
      //                 onPressed: () {},
      //                 icon: const Icon(
      //                   Icons.send_outlined,
      //                   size: 25.0,
      //                 ),
      //                 label: const Text(
      //                   "Submit Anyway",
      //                   style: TextStyle(
      //                     fontSize: 16.0,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               )
      //             ],
      //           ),
      //         ),
      //       );
      //     },
      //   );
      //   return;
      // }
      _globalDialogHelper.buildCircularProgressWithTextCenter(
          context: context, message: "Submitting");
      var response = await _feedbackServices.postFeedback(
        rating: _feedbackValue.toInt(),
        services: selectedIndexes,
        comment: text,
      );
      if (response == "201") {
        Navigator.of(context).pop();
        _showDoneDialog();
      }
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Error in sending feedback. Please try again",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "How's your experience with our services?\nSend your feedback to us",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _ratingBarWidget(_feedbackValue),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Very Dissatisfied"),
                          Text("Very Satisfied")
                        ],
                      ),
                    )
                  ],
                ),
              ),
              ..._handleFeedbackForm(),
              _titleWidget("Tell us more about it"),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: TextField(
                  controller: _textEditingController,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  focusNode: _focusNode,
                  // onChanged callback will be called whenever the user types in the text field
                  onChanged: (String value) {
                    print("Typed: $value");
                  },
                  style: const TextStyle(
                    fontSize: 15.0,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Briefly describe your experience so we can understand it better',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: screenSize.width * 0.9,
                height: Platform.isIOS
                    ? screenSize.height * 0.05
                    : screenSize.height * 0.05,
                child: ElevatedButton(
                  onPressed: () {
                    // Perform any action needed with the entered text
                    String enteredText = _textEditingController.text;

                    _handleSubmitFeedback(enteredText);
                  },
                  child: const Text(
                    "Send Feedback",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleWidget(String title) => Container(
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _ratingBarWidget(double rate) => Container(
        margin: const EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
        ),
        child: RatingBar.builder(
          initialRating: rate,
          minRating: 1,
          direction: Axis.horizontal,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemSize: 50.0,
          onRatingUpdate: (rating) {
            _handleFeedbackWord(rating, rate);
          },
        ),
      );

  List<Widget> _handleFeedbackForm() {
    return [
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: const Text(
          "What should we improve on?",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(10.0),
        child: const Text("Select all that apply"),
      ),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap:
              true, // Ensure the GridView doesn't try to take infinite height
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3.5 / 1,
          ),
          itemCount: 8, // Number of containers you want to display
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _handleIndex(index);
                print(index);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: selectedIndexes.contains(index)
                        ? Theme.of(context).primaryColor
                        : null,
                    border: Border.all(
                      color: selectedIndexes.contains(index)
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      width: selectedIndexes.contains(index) ? 1.5 : 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                child: Center(
                  child: Text(
                    _handleGridText(index),
                    style: TextStyle(
                      color: selectedIndexes.contains(index)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(
        height: 10.0,
      ),
    ];
  }
}