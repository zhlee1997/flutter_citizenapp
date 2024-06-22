import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SubscriptionVideoScreenLS extends StatefulWidget {
  static const String routeName = "subscription-video-screen-ls";

  const SubscriptionVideoScreenLS({super.key});

  @override
  State<SubscriptionVideoScreenLS> createState() =>
      _SubscriptionVideoScreenLSState();
}

class _SubscriptionVideoScreenLSState extends State<SubscriptionVideoScreenLS> {
  final GlobalKey _webviewKey = GlobalKey();
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Linking Vision'),
        bottom: loadingPercentage < 100
            ? PreferredSize(
                preferredSize:
                    const Size.fromHeight(1.0), // Adjust the height as needed
                child: LinearProgressIndicator(
                  value: loadingPercentage / 100.0,
                ),
              )
            : null,
      ),
      body: InAppWebView(
        key: _webviewKey,
        initialUrlRequest: URLRequest(
          url: WebUri(
              "https://10.16.24.144:18445/ws.html?token=0ba9--03445253977265490101_2450e628c6654835a282faf5e4185d8b&session=1aa43ca0-8e85-4041-9368-77503d1e0dbb"),
        ),
        onWebViewCreated: (InAppWebViewController controller) {},
        onLoadStart: (InAppWebViewController controller, Uri? url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgressChanged: (_, int progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) async {},
        onReceivedError: (
          InAppWebViewController controller,
          WebResourceRequest webResourceRequest,
          WebResourceError webResourceError,
        ) {},
      ),
    );
  }
}
