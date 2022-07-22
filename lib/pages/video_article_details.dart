import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:el_horizonte/blocs/ads_bloc.dart';
import 'package:el_horizonte/blocs/bookmark_bloc.dart';
import 'package:el_horizonte/blocs/sign_in_bloc.dart';
import 'package:el_horizonte/blocs/theme_bloc.dart';
import 'package:el_horizonte/models/article.dart';
import 'package:el_horizonte/models/custom_color.dart';
import 'package:el_horizonte/pages/comments.dart';
import 'package:el_horizonte/services/app_service.dart';
import 'package:el_horizonte/utils/cached_image.dart';
import 'package:el_horizonte/utils/sign_in_dialog.dart';
import 'package:el_horizonte/widgets/bookmark_icon.dart';
import 'package:el_horizonte/widgets/html_body.dart';
import 'package:el_horizonte/widgets/love_count.dart';
import 'package:el_horizonte/widgets/love_icon.dart';
import 'package:el_horizonte/widgets/related_articles.dart';
import 'package:el_horizonte/widgets/views_count.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:io';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/next_screen.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:just_audio/just_audio.dart';

class VideoArticleDetails extends StatefulWidget {
  final Article? data;
  const VideoArticleDetails({Key? key, required this.data}) : super(key: key);

  @override
  _VideoArticleDetailsState createState() => _VideoArticleDetailsState();
}

class BufferAudioSource extends StreamAudioSource {
  Uint8List _buffer;

  BufferAudioSource(this._buffer) : super();

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) {
    start = start ?? 0;
    end = end ?? _buffer.length;

    return Future.value(
      StreamAudioResponse(
        sourceLength: _buffer.length,
        contentLength: end - start,
        offset: start,
        contentType: 'audio/mpeg',
        stream:
            Stream.value(List<int>.from(_buffer.skip(start).take(end - start))),
      ),
    );
  }
}

class _VideoArticleDetailsState extends State<VideoArticleDetails> {
  final FijkPlayer player = FijkPlayer();
  double rightPaddingValue = 130;

  // late YoutubePlayerController _controller;

  // initYoutube() async {
  //  _controller = YoutubePlayerController(
  //      initialVideoId: widget.data!.videoID!,
  //      flags: YoutubePlayerFlags(
  //        autoPlay: false,
  //        mute: false,
  //        forceHD: false,
  //        loop: true,
  //        controlsVisibleAtStart: false,
  //        enableCaption: false,
  //      ));
  // }

  void _handleShare() {
    final sb = context.read<SignInBloc>();
    final String _shareTextAndroid =
        '${widget.data!.title}, Check out this app to explore more. App link: https://play.google.com/store/apps/details?id=${sb.packageName}';
    final String _shareTextiOS =
        '${widget.data!.title}, Check out this app to explore more. App link: https://play.google.com/store/apps/details?id=${sb.packageName}';

    if (Platform.isAndroid) {
      Share.share(_shareTextAndroid);
    } else {
      Share.share(_shareTextiOS);
    }
  }

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context.read<BookmarkBloc>().onLoveIconClick(widget.data!.id);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context.read<BookmarkBloc>().onBookmarkIconClick(widget.data!.id);
    }
  }

  _initInterstitialAds() {
    final adb = context.read<AdsBloc>();
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      if (adb.interstitialAdEnabled == true) {
        context.read<AdsBloc>().loadAds();
      }
    });
  }

  late AudioPlayer audioplayer;
  @override
  void initState() {
    super.initState();
    final Article d = widget.data!;
    //debugPrint(d.video!);
    player.setDataSource(d.video!, autoPlay: false);
    audioplayer = AudioPlayer();
    AzureTts.init(
        subscriptionKey: "243d954d0cb545b5a2ce1dd16c9429d0",
        region: "eastus",
        withLogs: true);
    ttsAzure();
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      setState(() {
        rightPaddingValue = 10;
      });
    });
  }

  // @override
  // void initState() {
  //  super.initState();
  // initYoutube();
  //  _initInterstitialAds();
  //  Future.delayed(Duration(milliseconds: 100)).then((value) {
  //    setState(() {
  //      rightPaddingValue = 10;
  //    });
  //  });
  // }

  // @override
  // void dispose() {
  //  _controller.dispose();
  //  super.dispose();
  // }

  @override
  void dispose() {
    super.dispose();
    player.release();
    audioplayer.dispose();
  }

  // @override
  // void deactivate() {
  //  _controller.pause();
  //  super.deactivate();
  // }

  void ttsAzure() async {
    final Article article = widget.data!;

    final voicesResponse = await AzureTts.getAvailableVoices() as VoicesSuccess;

    final voice = voicesResponse.voices
        .where((element) =>
            element.voiceType == "Neural" && element.locale.startsWith("es-MX"))
        .toList(growable: true)[1];
    // final text = article.description!;
    final text = Bidi.stripHtmlIfNeeded(article.description!);
    // print(text);

    TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.0,
        text: text);
    final ttsResponse = await AzureTts.getTts(params) as AudioSuccess;
    // audioplayer.play();
    // audioplayer.pause();

    await audioplayer.setAudioSource(BufferAudioSource(ttsResponse.audio));
  }

  void _play(isSelected) {
    debugPrint("play: " + isSelected.toString());
    audioplayer.play();
  }

  void _pause(isSelected) {
    debugPrint("pause: " + isSelected.toString());
    audioplayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    final Article d = widget.data!;
    final Article article = widget.data!;

    var parsedDate = DateTime.parse(article.date!);
    var finalDate = timeago.format(parsedDate, locale: 'es');
    bool isSelected = false;
    return Scaffold(
        body: SafeArea(
            bottom: false,
            top: true,
            maintainBottomViewPadding: true,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      child: FijkView(
                        player: player,
                        color: Colors.black,
                        height: 240,
                        width: 600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Ink(
                            decoration: ShapeDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              color: Colors.black,
                              iconSize: 22,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Spacer(),
                          d.sourceUrl == null
                              ? Container()
                              : Ink(
                                  decoration: ShapeDecoration(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    shape: CircleBorder(),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.launch),
                                    color: Colors.black,
                                    iconSize: 22,
                                    onPressed: () => AppService()
                                        .openLinkWithCustomTab(
                                            context, d.sourceUrl!),
                                  ),
                                ),
                          Ink(
                            decoration: ShapeDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.ios_share),
                              color: Colors.black,
                              iconSize: 22,
                              onPressed: () {
                                _handleShare();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: <Widget>[
                                  Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: context
                                                    .watch<ThemeBloc>()
                                                    .darkTheme ==
                                                false
                                            ? CustomColor().loadingColorLight
                                            : CustomColor().loadingColorDark,
                                      ),
                                      child: AnimatedPadding(
                                        duration: Duration(milliseconds: 1000),
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: rightPaddingValue,
                                            top: 5,
                                            bottom: 5),
                                        child: Text(
                                          d.category!,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )),
                                  Spacer(),
                                  IconButton(
                                      icon: BuildLoveIcon(
                                          collectionName: 'contents',
                                          uid: sb.uid,
                                          id: d.id),
                                      onPressed: () {
                                        handleLoveClick();
                                      }),
                                  IconButton(
                                      icon: BuildBookmarkIcon(
                                          collectionName: 'contents',
                                          uid: sb.uid,
                                          id: d.id),
                                      onPressed: () {
                                        handleBookmarkClick();
                                      }),
                                  IconButton(
                                      icon: Icon((isSelected == false)
                                          ? Icons.volume_up
                                          : Icons.pause),
                                      onPressed: () async => {
                                            if (isSelected == false)
                                              {
                                                isSelected = true,
                                                _play(isSelected)
                                              }
                                            else
                                              {
                                                isSelected = false,
                                                _pause(isSelected)
                                              }
                                          }),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(CupertinoIcons.time_solid,
                                      size: 20, color: Colors.grey),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    finalDate,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                d.title!,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.6,
                                    wordSpacing: 1),
                              ),
                              Divider(
                                color: Theme.of(context).primaryColor,
                                endIndent: 200,
                                thickness: 2,
                                height: 20,
                              ),
                              TextButton.icon(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.resolveWith(
                                      (states) =>
                                          EdgeInsets.only(left: 10, right: 10)),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) =>
                                              Theme.of(context).primaryColor),
                                  shape: MaterialStateProperty.resolveWith(
                                      (states) => RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3))),
                                ),
                                icon: Icon(Feather.message_circle,
                                    color: Colors.white, size: 20),
                                label: Text('comments',
                                        style: TextStyle(color: Colors.white))
                                    .tr(),
                                onPressed: () {
                                  nextScreen(context,
                                      CommentsPage(timestamp: d.timestamp));
                                },
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //views feature
                                  ViewsCount(
                                    article: d,
                                  ),
                                  // SizedBox(
                                  //  width: 20,
                                  // ),

                                  // LoveCount(
                                  //    collectionName: 'contents',
                                  //    timestamp: d.timestamp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        HtmlBodyWidget(
                          content: d.description!,
                          isIframeVideoEnabled: false,
                          isVideoEnabled: false,
                          isimageEnabled: true,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            padding: EdgeInsets.all(20),
                            child: RelatedArticles(
                              category: d.category,
                              timestamp: d.timestamp,
                              replace: true,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}
