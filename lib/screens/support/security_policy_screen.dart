import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SecurityPolicyScreen extends StatefulWidget {
  static const String routeName = "security-policy-screen";

  const SecurityPolicyScreen({super.key});

  @override
  State<SecurityPolicyScreen> createState() => _SecurityPolicyScreenState();
}

class _SecurityPolicyScreenState extends State<SecurityPolicyScreen> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Policy"),
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
        initialUrlRequest: URLRequest(
          url: WebUri(
              "https://sarawak.gov.my/web/home/article_view/250/261/?id=250"),
        ),
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
        onLoadStop: (InAppWebViewController controller, Uri? url) async {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onReceivedError: (
          InAppWebViewController controller,
          WebResourceRequest webResourceRequest,
          WebResourceError webResourceError,
        ) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ),
    );
  }
}
