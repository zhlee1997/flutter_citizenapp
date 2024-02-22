import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      ),
      body: FutureBuilder(
          future: rootBundle.loadString(_url),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Markdown(data: snapshot.data ?? "");
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
