import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:el_horizonte/blocs/sign_in_bloc.dart';
import 'package:el_horizonte/utils/empty.dart';
import 'package:provider/provider.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:easy_localization/easy_localization.dart';

class LiveTVPage extends StatefulWidget {
  @override
  _LiveTVPageState createState() => _LiveTVPageState();
}

class _LiveTVPageState extends State<LiveTVPage> {
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    player.setDataSource("https://live.info7.mx/info7/stream.m3u8",
        autoPlay: true);
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('tv').tr(),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FijkView(
          player: player,
          color: Colors.black,
        ),
      ),
    );
  }
}
