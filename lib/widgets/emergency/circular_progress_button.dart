import 'dart:async';

import 'package:flutter/material.dart';

import './circular_button.dart';

class CircularProgressButton extends StatefulWidget {
  final VoidCallback startCountdown;
  final VoidCallback resetCountdown;
  final VoidCallback saveRecording;

  const CircularProgressButton({
    required this.startCountdown,
    required this.resetCountdown,
    required this.saveRecording,
    super.key,
  });

  @override
  State<CircularProgressButton> createState() => _CircularProgressButtonState();
}

class _CircularProgressButtonState extends State<CircularProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleTransition;
  double _progress = 0.0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 9000,
      ),
      reverseDuration: const Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    _scaleTransition = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _progress = _scaleTransition.value - 0.5;
        });

        if (_progress == 1) {
          _scaleTransition.removeListener(() {});
          _controller.stop();
        }
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Future.delayed(const Duration(seconds: 1), () {
          _controller.forward();
        });
        widget.startCountdown();
      },
      // onLongPressDown: (LongPressDownDetails longPressDownDetails) {
      //   Future.delayed(const Duration(microseconds: 100), () {
      //     widget.startCountdown();
      //   });

      //   setState(() {
      //     _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      //       setState(() {
      //         // countdown value
      //         widget.startCountdown();

      //         _controller.forward();
      //       });
      //     });
      //   });
      // },
      onLongPressUp: () {
        // widget.resetCountdown();
        widget.saveRecording();

        setState(() {
          // countdown value

          _controller.reverse();
          _timer?.cancel();
        });
      },
      onLongPressCancel: () {
        // widget.resetCountdown();
        widget.saveRecording();

        setState(() {
          // countdown value

          _controller.reverse();
          _timer?.cancel();
        });
      },
      child: CircularButton(
        progress: _progress,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import './circular_button.dart';

// class CircularProgressButton extends StatefulWidget {
//   const CircularProgressButton({super.key});

//   @override
//   State<CircularProgressButton> createState() => _CircularProgressButtonState();
// }

// class _CircularProgressButtonState extends State<CircularProgressButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleTransition;
//   double _progress = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 10000),
//       reverseDuration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _scaleTransition = Tween<double>(begin: 0.5, end: 1.5).animate(_controller)
//       ..addListener(() {
//         setState(() {
//           _progress = _scaleTransition.value - 0.5;
//         });

//         if (_progress == 1) {
//           _scaleTransition.removeListener(() {});
//           _controller.stop();
//         }
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (details) {
//         _controller.forward();
//       },
//       onTapUp: (TapUpDetails details) {
//         _controller.reverse();
//       },
//       child: ScaleTransition(
//           scale: _scaleTransition,
//           child: CircularButton(
//             progress: _progress,
//           )),
//     );
//   }
// }

