import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SecurityPolicyScreen extends StatelessWidget {
  static const String routeName = "security-policy-screen";

  const SecurityPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Policy"),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(
              "https://sarawak.gov.my/web/home/article_view/250/261/?id=250"),
        ),
      ),
    );
  }
}
