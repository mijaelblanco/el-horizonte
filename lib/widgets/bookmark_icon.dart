import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:el_horizonte/blocs/sign_in_bloc.dart';
import 'package:el_horizonte/utils/icons.dart';
import 'package:provider/provider.dart';

class BuildBookmarkIcon extends StatelessWidget {
  final String collectionName;
  final String? uid;
  final String? id;

  const BuildBookmarkIcon(
      {Key? key,
      required this.collectionName,
      required this.uid,
      required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    String _type = 'bookmarked items';
    if (sb.isSignedIn == false) return BookmarkIcon().normal;
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, AsyncSnapshot snap) {
        if (uid == null) return BookmarkIcon().normal;
        if (!snap.hasData) return BookmarkIcon().normal;
        List d = snap.data[_type];

        if (d.contains(id)) {
          return BookmarkIcon().bold;
        } else {
          return BookmarkIcon().normal;
        }
      },
    );
  }
}
