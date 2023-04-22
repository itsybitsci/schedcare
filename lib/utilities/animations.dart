import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

Center lottieLoadingScreen() => Center(
      child: Lottie.asset('assets/animations/paper-plane_lottie.json',
          width: 500.w),
    );

Center lottieLoading({double width = 200}) => Center(
      child: Lottie.asset('assets/animations/circular-loading_lottie.json',
          width: width.w),
    );

Center lottieDiamondLoading() => Center(
      child: Lottie.asset('assets/animations/diamond-loading_lottie.json',
          width: 50.w),
    );

Center lottieError() => Center(
      child: Lottie.asset('assets/animations/no-connection_lottie.json',
          width: 200.w),
    );

Center lottieCrying() => Center(
      child: Lottie.asset('assets/animations/crying_lottie.json', width: 200.w),
    );

Center lottieForgotPassword() => Center(
      child: Lottie.asset('assets/animations/forgot-password_lottie.json',
          width: 500.w),
    );

Center lottieRegister() => Center(
      child:
          Lottie.asset('assets/animations/register_lottie.json', width: 150.w),
    );
