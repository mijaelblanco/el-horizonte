import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:el_horizonte/blocs/categories_bloc.dart';
import 'package:el_horizonte/models/category.dart';
import 'package:el_horizonte/pages/category_based_articles.dart';
import 'package:el_horizonte/utils/cached_image_with_dark.dart';
import 'package:el_horizonte/utils/empty.dart';
import 'package:el_horizonte/utils/loading_cards.dart';
import 'package:el_horizonte/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:io';
import '../widgets/language.dart';

class Subscriptions extends StatefulWidget {
  Subscriptions({Key? key}) : super(key: key);

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  bool isLoading = true;

  late WebViewController webView;

  Future<bool> _onBack() async {
    var value = await webView.canGoBack();

    if (value) {
      await webView.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBack(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              alignment: Alignment.center,
              padding: EdgeInsets.all(0),
              iconSize: 22,
              icon: Icon(
                Icons.language,
              ),
              onPressed: () {
                nextScreenPopup(context, LanguagePopup());
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              WebView(
                initialUrl:
                    'https://registro.elhorizonte.mx/correo-celular?fuente=icono-header-suscribete',
                javascriptMode: JavascriptMode.unrestricted,
                onPageStarted: (url) {
                  setState(() {
                    isLoading = true;
                  });
                },
                onPageFinished: (status) {
                  setState(() {
                    isLoading = false;
                  });
                },
                onWebViewCreated: (WebViewController controller) {
                  webView = controller;
                },
              ),
              isLoading
                  ? Center(
                      child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: CircularProgressIndicator(),
                    ))
                  : Stack(),
            ],
          ),
        ),
      ),
    );
  }
}
