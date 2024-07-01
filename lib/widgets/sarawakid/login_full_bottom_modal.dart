import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/sarawakid/sarawakid_screen.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/app_localization.dart';

class LoginFullBottomModal extends StatelessWidget {
  const LoginFullBottomModal({super.key});

  void handleNavigateSarawakIDScreen(BuildContext context) =>
      Navigator.of(context).pushNamed(SarawakIDScreen.routeName);

  void openExternalBrowser() {
    final Uri uri =
        Uri.parse("https://sarawakid-tnt.sarawak.gov.my/web/ssov1/signup/");
    launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.clear_outlined,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: Image.asset(
                  "assets/images/icon/app_logo.png",
                  width: screenSize.width * 0.75,
                  height: screenSize.width * 0.75,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: screenSize.width * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.of(context)!.translate('hey_there')!,
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Text(AppLocalization.of(context)!
                        .translate('login_to_your_account')!)
                  ],
                ),
              ),
              SizedBox(
                height: screenSize.height * 0.075,
              ),
              Container(
                width: screenSize.width * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.15, 0.55],
                    colors: [
                      Theme.of(context).colorScheme.error,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () => handleNavigateSarawakIDScreen(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/icon/sarawakid_logo.png",
                        width: screenSize.width * 0.1,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        AppLocalization.of(context)!
                            .translate('sign_in_with_sarawakid')!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: screenSize.width * 0.8,
                child: const Divider(),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                AppLocalization.of(context)!.translate('not_yet_have_account')!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: screenSize.width * 0.75,
                child: OutlinedButton(
                  onPressed: () async {
                    await GlobalDialogHelper().showAlertDialog(
                      context: context,
                      yesButtonFunc: () {
                        Navigator.of(context).pop();
                        openExternalBrowser();
                      },
                      title: AppLocalization.of(context)!
                          .translate('new_registration')!,
                      message: AppLocalization.of(context)!
                          .translate('you_can_use_browser')!,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(AppLocalization.of(context)!
                          .translate('sign_up_with_sarawakid')!),
                      const SizedBox(
                        width: 10.0,
                      ),
                      const Icon(
                        Icons.open_in_new_outlined,
                        size: 20.0,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
