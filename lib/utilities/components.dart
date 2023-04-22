import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    this.topImage = "assets/images/bg_top.png",
    this.bottomImage = "assets/images/bg_bottom.png",
  }) : super(key: key);

  final String topImage, bottomImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                topImage,
                width: 120,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(bottomImage, width: 120),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Background(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/paper-plane_lottie.json',
                    width: 500.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
