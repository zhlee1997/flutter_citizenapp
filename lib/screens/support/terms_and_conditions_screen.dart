import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import '../../utils/app_localization.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  static const String routeName = "terms-and-condition-screen";

  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String _url = "";
  var loadingPercentage = 0;

  @override
  void initState() {
    _url = "assets/t&c/t&c_en.md";
    super.initState();
  }

  @override
  void didChangeDependencies() {
    String languageCode = AppLocalization.of(context)!.locale.languageCode;
    if (languageCode == "zh") {
      _url = "assets/t&c/t&c_zh.md";
    } else if (languageCode == "ms") {
      _url = "assets/t&c/t&c_ms.md";
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.of(context)!.translate('terms_cond')!),
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
              "https://sarawak.gov.my/web/home/article_view/253/289/?id=253"),
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
      // FutureBuilder(
      //     future: rootBundle.loadString(_url),
      //     builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      //       if (snapshot.hasData) {
      //         return Markdown(data: snapshot.data ?? "");
      //       }

      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }),
    );
  }
}
