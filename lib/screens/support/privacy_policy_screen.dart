import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import '../../utils/app_localization.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String routeName = "privacy-policy-screen";

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _url = "";

  @override
  void initState() {
    _url = "assets/privacy/privacy_en.md";
    super.initState();
  }

  @override
  void didChangeDependencies() {
    String languageCode = AppLocalization.of(context)!.locale.languageCode;
    if (languageCode == "zh") {
      _url = "assets/privacy/privacy_zh.md";
    } else if (languageCode == "ms") {
      _url = "assets/privacy/privacy_ms.md";
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.of(context)!.translate('privacy_poli')!),
      ),
      body: FutureBuilder(
          future: rootBundle.loadString(_url),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data ?? "",
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
