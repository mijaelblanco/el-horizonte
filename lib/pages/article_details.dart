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
import 'package:el_horizonte/widgets/banner_ad_admob.dart'; //admob
//import 'package:el_horizonte/widgets/banner_ad_fb.dart'; //fb ad
import 'package:el_horizonte/widgets/bookmark_icon.dart';
import 'package:el_horizonte/widgets/html_body.dart';
import 'package:el_horizonte/widgets/love_count.dart';
import 'package:el_horizonte/widgets/related_articles.dart';
import 'package:el_horizonte/widgets/views_count.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/next_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:flutter_azure_tts/src/audio/audio_output_format.dart';
import 'package:flutter_azure_tts/src/tts/tts_params.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import '../widgets/love_icon.dart';

class ArticleDetails extends StatefulWidget {
  final Article? data;
  final String? tag;

  const ArticleDetails({Key? key, required this.data, required this.tag})
      : super(key: key);

  @override
  _ArticleDetailsState createState() => _ArticleDetailsState();
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

class _ArticleDetailsState extends State<ArticleDetails> {
  double rightPaddingValue = 130;

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

  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
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

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void ttsAzure() async {
    final Article article = widget.data!;

    final voicesResponse = await AzureTts.getAvailableVoices() as VoicesSuccess;

    final voice = voicesResponse.voices
        .where((element) =>
            element.voiceType == "Neural" && element.locale.startsWith("es-MX"))
        .toList(growable: true)[1];
    //final text = article.description!;
    final text = Bidi.stripHtmlIfNeeded(article.description!);
    //print(text);

    TtsParams params = TtsParams(
        voice: voice,
        audioFormat: AudioOutputFormat.audio16khz32kBitrateMonoMp3,
        rate: 1.0,
        text: text);
    final ttsResponse = await AzureTts.getTts(params) as AudioSuccess;
    await player.setAudioSource(BufferAudioSource(ttsResponse.audio));
  }

  void _play(isSelected) {
    debugPrint("play: " + isSelected.toString());
    player.play();
  }

  void _pause(isSelected) {
    debugPrint("pause: " + isSelected.toString());
    player.pause();
  }

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    final Article article = widget.data!;

    var parsedDate = DateTime.parse(article.date!);
    var finalDate = timeago.format(parsedDate, locale: 'es');
    bool isSelected = false;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: true,
          top: false,
          maintainBottomViewPadding: true,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    _customAppBar(article, context),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: context
                                                          .watch<ThemeBloc>()
                                                          .darkTheme ==
                                                      false
                                                  ? CustomColor()
                                                      .loadingColorLight
                                                  : CustomColor()
                                                      .loadingColorDark,
                                            ),
                                            child: AnimatedPadding(
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: rightPaddingValue,
                                                  top: 5,
                                                  bottom: 5),
                                              child: Text(
                                                article.category!,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )),
                                        Spacer(),
                                        IconButton(
                                            icon: BuildLoveIcon(
                                                collectionName: 'contents',
                                                uid: sb.uid,
                                                id: article.id),
                                            onPressed: () {
                                              handleLoveClick();
                                            }),
                                        IconButton(
                                            icon: BuildBookmarkIcon(
                                                collectionName: 'contents',
                                                uid: sb.uid,
                                                id: article.id),
                                            onPressed: () async {
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
                                        ViewsCount(
                                          article: article,
                                        ),
                                        Icon(CupertinoIcons.time_solid,
                                            size: 18, color: Colors.grey),
                                        SizedBox(width: 3),
                                        Text(
                                          finalDate,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      article.title!,
                                      style: TextStyle(
                                          fontSize: 22,
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
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                                (states) => EdgeInsets.only(
                                                    left: 10, right: 10)),
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) => Theme.of(context)
                                                    .primaryColor),
                                        shape:
                                            MaterialStateProperty.resolveWith(
                                                (states) =>
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3))),
                                      ),
                                      icon: Icon(Feather.message_circle,
                                          color: Colors.white, size: 20),
                                      label: Text('comments',
                                              style: TextStyle(
                                                  color: Colors.white))
                                          .tr(),
                                      onPressed: () {
                                        nextScreen(
                                            context,
                                            CommentsPage(
                                                timestamp: article.timestamp));
                                      },
                                    ),
                                    SizedBox(
                                      height: 0,
                                    ),
                                  ],
                                ),
                              ),
                              HtmlBodyWidget(
                                content: article.description!,
                                isIframeVideoEnabled: true,
                                isVideoEnabled: true,
                                isimageEnabled: true,
                              ),
                              SizedBox(
                                height: 0,
                              ),
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.all(20),
                              child: RelatedArticles(
                                category: article.category,
                                timestamp: article.timestamp,
                                replace: true,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // -- Banner ads --

              context.watch<AdsBloc>().bannerAdEnabled == false
                  ? Container()
                  : BannerAdAdmob() //admob
              //: BannerAdFb()      //fb
            ],
          ),
        ));
  }

  SliverAppBar _customAppBar(Article article, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 270,
      flexibleSpace: FlexibleSpaceBar(
          background: widget.tag == null
              ? CustomCacheImage(
                  imageUrl: article.thumbnailImagelUrl, radius: 0.0)
              : Hero(
                  tag: widget.tag!,
                  child: CustomCacheImage(
                      imageUrl: article.thumbnailImagelUrl, radius: 0.0),
                )),
      leading: Ink(
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
      actions: <Widget>[
        article.sourceUrl == null
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
                      .openLinkWithCustomTab(context, article.sourceUrl!),
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
        SizedBox(
          width: 5,
        )
      ],
    );
  }
}
