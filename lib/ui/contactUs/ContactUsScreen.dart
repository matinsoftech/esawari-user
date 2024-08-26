import 'package:easy_localization/easy_localization.dart';
import 'package:emartconsumer/constants.dart';
import 'package:emartconsumer/services/FirebaseHelper.dart';
import 'package:emartconsumer/services/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../AppGlobal.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String address = "", phone = "", email = "";

  @override
  void initState() {
    super.initState();
    FireStoreUtils().getContactUs().then((value) {
      setState(() {
        address = value['Address'];
        phone = value['Phone'];
        email = value['Email'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'Contact Us',
        onPressed: () {
          String url = 'tel:$phone';
          launch(url);
        },
        backgroundColor: const Color(COLOR_ACCENT),
        child: Icon(
          CupertinoIcons.phone_solid,
          color: isDarkMode(context) ? Colors.black : Colors.white,
        ),
      ),
      appBar: AppGlobal.buildSimpleAppBar(context, "Contact Us".tr()),
      body: Column(children: <Widget>[
        Material(
            elevation: 2,
            color: isDarkMode(context) ? Colors.black12 : Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16, top: 16),
                child: Text(
                  'Our Address'.tr(),
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                ).tr(),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 16),
                child: Text(address.replaceAll(r'\n', '\n')),
              ),
              ListTile(
                title: Text(
                  'Email Us'.tr(),
                  style: TextStyle(color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                ).tr(),
                subtitle: Text(email),
                trailing: Icon(
                  CupertinoIcons.chevron_forward,
                  color: isDarkMode(context) ? Colors.white54 : Colors.black54,
                ),
              )
            ]))
      ]),
    );
  }
}
