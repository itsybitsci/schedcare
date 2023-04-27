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
          width: 30.w),
    );

Center lottieError() => Center(
      child: Lottie.asset('assets/animations/no-connection_lottie.json',
          width: 400.w),
    );

Center lottieForgotPassword() => Center(
      child: Lottie.asset('assets/animations/forgot-password_lottie.json',
          width: 500.w),
    );

Center lottieRegister() => Center(
      child:
          Lottie.asset('assets/animations/register_lottie.json', width: 150.w),
    );

Center lottieCalling() => Center(
      child:
          Lottie.asset('assets/animations/video-call_lottie.json', width: 30.w),
    );

Center lottieMale() => Center(
      child: Lottie.asset('assets/animations/male_lottie.json', width: 300.w),
    );

Center lottieFemale() => Center(
      child: Lottie.asset('assets/animations/female_lottie.json', width: 300.w),
    );

Center lottieNoData() => Center(
      child:
          Lottie.asset('assets/animations/no-data_lottie.json', width: 200.w),
    );

Center lottieNoNotifications() => Center(
      child: Lottie.asset('assets/animations/no-notifications_lottie.json',
          width: 300.w),
    );

Center lottieSearchDoctors() => Center(
      child: Lottie.asset('assets/animations/search-doctors_lottie.json',
          width: 50.w),
    );

Center lottieSearchUsers() => Center(
      child: Lottie.asset('assets/animations/search-users_lottie.json',
          width: 50.w),
    );
