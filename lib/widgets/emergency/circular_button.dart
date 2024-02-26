import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class CircularButton extends StatefulWidget {
  final double progress;

  const CircularButton({required this.progress, super.key});

  @override
  State<CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  var iconSize = 50.0;
  IconData _icon = Icons.fingerprint;
  bool _isDone = false;
  double? _height = 0.0;

  @override
  Widget build(BuildContext context) {
    _height = lerpDouble(iconSize, 0, widget.progress);

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.red,
        ),
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200,
              child: CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 6.0,
                color: Color(0xffE6E8FD),
              ),
            ),
            Container(
              // margin: EdgeInsets.symmetric(
              //   vertical: 40,
              // ),
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: Icon(
                _isDone ? Icons.check_circle : getIcon,
                size: iconSize,
                color: const Color(0xffE6E8FD),
              ),
            ),
            AnimatedContainer(
              margin: const EdgeInsets.symmetric(
                vertical: 40,
              ),
              alignment: Alignment.center,
              duration: const Duration(
                milliseconds: 200,
              ),
              height: _height,
              width: 200,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Icon(
                  Icons.fingerprint,
                  size: iconSize,
                  color: const Color(0xffE6E8FD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  get getIcon {
    setState(() {
      if (_height == 50) {
        print("_height");
      }
      if (_height == 0) {
        _icon = Icons.check_circle;
        _isDone = true;
      }
    });
    return _icon;
  }
}

// import 'dart:math' as math;
// import 'dart:ui';

// import 'package:flutter/material.dart';

// class CircularButton extends StatefulWidget {
//   final double progress;

//   const CircularButton({required this.progress, super.key});

//   @override
//   State<CircularButton> createState() => _CircularButtonState();
// }

// class _CircularButtonState extends State<CircularButton> {
//   var iconSize = 100.0;
//   IconData _icon = Icons.fingerprint;
//   bool _isDone = false;
//   double? _height = 0.0;

//   @override
//   Widget build(BuildContext context) {
//     _height = lerpDouble(iconSize, 0, widget.progress);

//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         height: 200,
//         width: 200,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(100),
//           color: Colors.white,
//         ),
//         child: Stack(
//           children: <Widget>[
//             Container(
//               width: double.infinity,
//               height: 200,
//               child: CircularProgressIndicator(
//                 value: widget.progress,
//                 strokeWidth: 16,
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 40),
//               width: 200,
//               height: 100,
//               alignment: Alignment.center,
//               child: Icon(
//                 _isDone ? Icons.check_circle : getIcon,
//                 size: iconSize,
//                 color: Colors.blue,
//               ),
//             ),
//             AnimatedContainer(
//               margin: EdgeInsets.symmetric(vertical: 40),
//               alignment: Alignment.center,
//               duration: Duration(milliseconds: 200),
//               height: _height,
//               width: 200,
//               child: SingleChildScrollView(
//                 physics: NeverScrollableScrollPhysics(),
//                 child: Icon(
//                   Icons.fingerprint,
//                   size: iconSize,
//                   color: Color(0xffE6E8FD),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   get getIcon {
//     setState(() {
//       if (_height == 50) {
//         print("_height");
//       }
//       if (_height == 0) {
//         _icon = Icons.check_circle;
//         _isDone = true;
//       }
//     });
//     return _icon;
//   }
// }
