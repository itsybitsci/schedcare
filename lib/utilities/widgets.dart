import 'package:flutter/material.dart';
import 'package:schedcare/utilities/helpers.dart';

Widget materialLoading({String toastMessage = ''}) {
  if (toastMessage != '') {
    showToast(toastMessage);
  }
  return const Material(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
