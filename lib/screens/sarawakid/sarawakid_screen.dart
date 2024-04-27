import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import "../../providers/auth_provider.dart";
import "../../providers/inbox_provider.dart";
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
              .signInProvider(userData);

      if (response != null) {
        await Provider.of<AuthProvider>(context, listen: false)
            .queryLoginUserInfo(
                response['userId']!, response['isSubscribed'] == 'true')
            .then((bool isLoginSuccess) {
          if (isLoginSuccess) {
            Provider.of<InboxProvider>(context, listen: false).refreshCount();
            _pushNotification.setFirebase(true).then((_) {
              if (mounted) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('home-page-screen'));
                // show snackbar after successful login
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Login successfully!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
            Provider.of<AuthProvider>(context, listen: false)
                .removeAuthByForce();
          }
        });
      } else {
        Fluttertoast.showToast(
          msg: AppLocalization.of(context)!.translate('login_error')!,
        );
        Provider.of<AuthProvider>(context, listen: false).removeAuthByForce();
      }
    } catch (e) {
      print("signIn fail: ${e.toString()}");
      _webViewController.loadData(
          data:
              """<h1>Unable to log in</h1><br/><h2>An unexpected error occured.</h2><h2>Please try login again.</h2>""");
      Provider.of<AuthProvider>(context, listen: false).removeAuthByForce();
    }
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
            redirect_uri: 'http://124.70.29.113:28300/mobile/api/login/auth/callback/',
            logout_redirect_url: 'http://124.70.29.113:28300/redirect/',
            logout_uri: 'http://124.70.29.113:28300/redirect/',
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
          // TODO: to change the IP Address when switch environment
          if (url.toString().contains('124.70.29.113:28300/loading.html')) {
            _webViewController.loadData(
                data:
                    """<h1>Signing In. Please wait.</h1><br/><h1>Do not close the page.</h1>""");
            print("loginUrl: $url");
            // detect "userId" redirect by backend
            if (url!.queryParameters["userId"] != null) {
              await signIn(url.queryParameters);
            } else {
              _webViewController.loadData(
                  data:
                      """<h1>Unable to log in</h1><br/><h2>An unexpected error occured.</h2><h2>Please try login again.</h2>""");
              Fluttertoast.showToast(msg: "Unable to log in");
            }
          }
          setState(() {
            loadingPercentage = 100;
          });
        },
        onReceivedError: (
          InAppWebViewController controller,
          WebResourceRequest webResourceRequest,
          WebResourceError webResourceError,
        ) {
          _webViewController.loadData(
              data:
                  """<h1>Unable to log in</h1><br/><h2>An unexpected error occured: ${webResourceError.description}.</h2><h2>Please try login again.</h2>""");
          Fluttertoast.showToast(msg: "Unable to log in");
          setState(() {
            loadingPercentage = 100;
          });
        },
      ),
    );
  }
}
