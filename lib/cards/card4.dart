import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:el_horizonte/models/article.dart';
import 'package:el_horizonte/utils/cached_image.dart';
import 'package:el_horizonte/utils/next_screen.dart';
import 'package:el_horizonte/widgets/video_icon.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../blocs/theme_bloc.dart';

class Card4 extends StatelessWidget {
  final Article d;
  final String heroTag;
  const Card4({Key? key, required this.d, required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tb = context.watch<ThemeBloc>();
    var parsedDate = DateTime.parse(d.date!);
    var finalDate = timeago.format(parsedDate, locale: 'es');
    return InkWell(
      child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3))
              ]),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Hero(
                              tag: heroTag,
                              child: CustomCacheImage(
                                  imageUrl: d.thumbnailImagelUrl, radius: 5.0)),
                        ),
                        VideoIcon(
                          contentType: d.contentType,
                          iconSize: 40,
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          d.title!,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: tb.darkTheme == false
                                  ? Color.fromARGB(255, 239, 239, 239)
                                  : Color.fromARGB(255, 51, 51, 51)),
                          child: Text(
                            " " + finalDate + "  |  " + d.category! + " ",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: tb.darkTheme == false
                                    ? Color.fromARGB(255, 70, 70, 70)
                                    : Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Row(
              //   children: <Widget>[
              //     Icon(
              //       CupertinoIcons.time,
              //       color: Colors.grey,
              //       size: 20,
              //     ),
              //     SizedBox(
              //       width: 5,
              //     ),
              //     Text(
              //       d.date!,
              //       style: TextStyle(
              //           color: Theme.of(context).secondaryHeaderColor,
              //           fontSize: 13),
              //     ),
              //     // Spacer(),
              //     // Icon(
              //     //   Icons.favorite,
              //     //   color: Theme.of(context).secondaryHeaderColor,
              //     //   size: 20,
              //     // ),
              //     // SizedBox(
              //     //   width: 3,
              //     // ),
              //     // Text(d.loves.toString(),
              //     //     style: TextStyle(
              //     //         color: Theme.of(context).secondaryHeaderColor,
              //     //         fontSize: 13)),
              //   ],
              // )
            ],
          )),
      onTap: () => navigateToDetailsScreen(context, d, heroTag),
    );
  }
}
