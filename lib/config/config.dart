import 'package:flutter/material.dart';

class Config {
  final String appName = 'El Horizonte';
  final String splashIcon = 'assets/images/splash.png';
  final String supportEmail = 'mijael@whiteck.com';
  final String privacyPolicyUrl =
      'https://rc.elhorizonte.mx/html/aviso_privacidad.php';
  final String ourWebsiteUrl = 'https://www.elhorizonte.mx/contacto';
  final String iOSAppId = '000000';

  //social links
  static const String facebookPageUrl = 'https://www.facebook.com/elhorizonte/';
  static const String youtubeChannelUrl =
      'https://www.youtube.com/channel/UChFywcHgTkvygGIY71XfDKA';
  static const String twitterUrl = 'https://twitter.com/elhorizontemx';

  //app theme color
  final Color appColor = Color.fromARGB(255, 213, 7, 7);

  //Intro images
  final String introImage1 = 'assets/images/news1.png';
  final String introImage2 = 'assets/images/news6.png';
  final String introImage3 = 'assets/images/news7.png';

  //animation files
  final String doneAsset = 'assets/animation_files/done.json';

  //Language Setup
  final List<String> languages = ['Spanish', 'English'];

  //initial categories - 4 only (Hard Coded : which are added already on your admin panel)
  final List initialCategories = [
    'Local',
    'Nacional',
    'Internacional',
    'Escena'
  ];
}
