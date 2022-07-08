import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:el_horizonte/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool? _subscribed;
  bool? get subscribed => _subscribed;

  Future handleFcmSubscribtion() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    bool _getsubcription = sp.getBool('subscribe') ?? true;
    if (_getsubcription == true) {
      await sp.setBool('subscribe', true);
      _fcm.subscribeToTopic(Constants.fcmSubscriptionTopic);
      _subscribed = true;
      notifyListeners();
      print('subscribed');
    } else {
      await sp.setBool('subscribe', false);
      _fcm.unsubscribeFromTopic(Constants.fcmSubscriptionTopic);
      _subscribed = false;
      notifyListeners();
      print('unsubscribed');
    }

    notifyListeners();
  }

  Future fcmSubscribe(bool isSubscribed) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('subscribe', isSubscribed);
    handleFcmSubscribtion();
  }
}
