import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:el_horizonte/models/article.dart';
import 'package:el_horizonte/utils/cached_image.dart';
import 'package:el_horizonte/utils/next_screen.dart';
import 'package:el_horizonte/widgets/video_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

class Card3 extends StatelessWidget {
  final Article d;
  final String? heroTag;
  final bool? replace;
  const Card3({Key? key, required this.d, required this.heroTag, this.replace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var parsedDate = DateTime.parse(d.date!);
    var finalDate = timeago.format(parsedDate, locale: 'es');
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: heroTag == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 100,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: CustomCacheImage(
                                imageUrl: d.thumbnailImagelUrl, radius: 5.0),
                          ),
                          VideoIcon(
                            contentType: d.contentType,
                            iconSize: 60,
                          )
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Hero(
                              tag: heroTag!,
                              child: CustomCacheImage(
                                  imageUrl: d.thumbnailImagelUrl, radius: 5.0),
                            ),
                          ),
                          VideoIcon(
                            contentType: d.contentType,
                            iconSize: 60,
                          )
                        ],
                      ),
              ),
              SizedBox(
                width: 15,
              ),
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      d.title!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Color.fromARGB(255, 51, 51, 51)),
                      child: Text(
                        " " + finalDate + "  |  " + d.category! + " ",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          )),
      onTap: () =>
          navigateToDetailsScreenByReplace(context, d, heroTag, replace),
    );
  }
}
