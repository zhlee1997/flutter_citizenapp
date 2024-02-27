import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import "../../providers/auth_provider.dart";
import '../../utils/app_localization.dart';
import '../../utils/notification/push_notification.dart';

class SarawakIDScreen extends StatefulWidget {
  static const routeName = 'sarawakid-screen';

  const SarawakIDScreen({super.key});

  @override
  State<SarawakIDScreen> createState() => _SarawakIDScreenState();
}

class _SarawakIDScreenState extends State<SarawakIDScreen> {
  final GlobalKey _webviewKey = GlobalKey();
  PushNotification _pushNotification = PushNotification();

  var uuid = const Uuid();
  var loadingPercentage = 0;

  late InAppWebViewController _webViewController;

  /// Sign in upon Sarawak ID authentication callback.
  /// Save user information into local storage.
  ///
  /// Receives [userData] as the user information from Sarawak ID
  Future<void> signIn(Map<String, String> userData) async {
    try {
      Map<String, String>? response =
          await Provider.of<AuthProvider>(context, listen: false)
              .signIn(userData);

      if (response != null) {
        await Provider.of<AuthProvider>(context, listen: false)
            .queryLoginUserInfo(
                response['userId']!, response['isSubscribed'] == 'true')
            .then((value) {
          if (value) {
            _pushNotification.setFirebase(true).then((_) {
              if (mounted) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('home-page-screen'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "You have login successfully",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                );
              }
            });
          } else {
            Fluttertoast.showToast(
              msg: AppLocalization.of(context)!.translate('login_error')!,
            );
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: AppLocalization.of(context)!.translate('login_error')!,
        );
      }
    } catch (e) {}
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
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
      body: InAppWebView(
        key: _webviewKey,
        initialData: InAppWebViewInitialData(
            data:
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
</script>"""),
        initialSettings: InAppWebViewSettings(
          incognito: true,
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        onLoadStart: (InAppWebViewController controller, Uri? url) {
          print("load start");
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
          if (url.toString().contains('citizen.sioc.sma.gov.my/loading.html')) {
            print("loginUrl: $url");

            if (url!.queryParameters["userId"] != null) {
              await signIn(url.queryParameters);
            } else {
              _webViewController.loadData(
                  data:
                      """<h1>Unable to log in</h1><br/><h2>An unexpected error occured.</h2><h2>Please try logging in again.</h2>""");
              Fluttertoast.showToast(msg: "Unable to log in");
            }
          }
          setState(() {
            loadingPercentage = 100;
          });
        },
        onReceivedError: (InAppWebViewController controller,
            WebResourceRequest webResourceRequest,
            WebResourceError webResourceError) {
          _webViewController.loadData(
              data:
                  """<h1>Unable to log in</h1><br/><h2>An unexpected error occured.</h2><h2>Please try logging in again.</h2>""");
          Fluttertoast.showToast(msg: "Unable to log in");
          setState(() {
            loadingPercentage = 100;
          });
        },
      ),
    );
  }
}