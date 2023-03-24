import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> showToast(String message) async {
  return await Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
  );
}
