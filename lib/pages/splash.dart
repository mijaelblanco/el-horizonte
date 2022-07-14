import 'package:flutter/material.dart';
import 'package:el_horizonte/config/config.dart';
import 'package:el_horizonte/pages/welcome.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/next_screen.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  afterSplash() {
    final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(Duration(milliseconds: 8100)).then((value) {
      sb.isSignedIn == true || sb.guestUser == true
          ? gotoHomePage()
          : gotoSignInPage();
    });
  }

  gotoHomePage() {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
    }
    nextScreenReplace(context, HomePage());
  }

  gotoSignInPage() {
    nextScreenReplace(context, WelcomePage());
  }

  @override
  void initState() {
    afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Lottie.asset(
          Config().splashAsset,
          alignment: Alignment.center,
          fit: BoxFit.fill,
          height: 1880,
          //width: 200,
          repeat: true,
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Theme.of(context).backgroundColor,
//         body: Center(
//             child: Image(
//           image: AssetImage(Config().splashIcon),
//           height: 1000,
//           width: 720,
//           fit: BoxFit.contain,
//         )));
//   }
// }
