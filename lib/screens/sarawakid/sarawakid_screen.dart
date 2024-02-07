import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';

class SarawakIDScreen extends StatefulWidget {
  static const routeName = 'sarawakid-screen';

  const SarawakIDScreen({super.key});

  @override
  State<SarawakIDScreen> createState() => _SarawakIDScreenState();
}

class _SarawakIDScreenState extends State<SarawakIDScreen> {
  var uuid = const Uuid();
  var loadingPercentage = 0;
  late final WebViewController controller;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
          """<script src="https://sarawakid-tnt.sarawak.gov.my/web/share/swkid_plugin/?lang=en"></script>
<script type="text/javascript" language="javascript">
    document.addEventListener("DOMContentLoaded", function () {
        swkid_sso_init({
            client_id: 'citizenapp_mobile_dev',
            state: '${uuid.v4()}',
            response_type: 'code',
            redirect_uri: 'https://citizen.sioc.sma.gov.my/mobile/api/login/auth/callback/',
            logout_redirect_url: 'https://citizen.sioc.sma.gov.my/redirect/',
            logout_uri: 'https://citizen.sioc.sma.gov.my/redirect/',
            misc_param: '',/*this will pass to redirect_uri*/
        });
        swkid_login_form_submit();
    });
</script>""");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Now to CitizenApp'),
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
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
