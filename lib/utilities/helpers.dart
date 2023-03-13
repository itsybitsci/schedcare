import 'package:fluttertoast/fluttertoast.dart';

Future<void> showToast(String message) async {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
  );
}
