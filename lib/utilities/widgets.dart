import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/plugins/videosdk_plugin/utils/videosdk_colors.dart';
import 'package:schedcare/providers/firebase_services_provider.dart';
import 'package:schedcare/providers/generic_fields_provider.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';
import 'package:schedcare/utilities/prompts.dart';
import 'package:shimmer/shimmer.dart';

Center loading({Color color = Colors.white}) => Center(
      child: CircularProgressIndicator(color: color),
    );

Shimmer shimmerListTile() => Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10.r),
        ),
        title: Center(
          child: Container(
              height: 90.h,
              width: 310.w,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(10.r),
              )),
        ),
      ),
    );

Align conversationHistoryChatWidget(String currentUserRole, String senderRole,
        String senderName, String message, DateTime timestamp) =>
    Align(
      alignment: currentUserRole == senderRole
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: message));
          showToast("Message has been copied");
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUserRole == senderRole ? "You" : senderName,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: VideoSdkColorConstants.black200,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('hh:mm a').format(timestamp.toLocal()),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

IconButton logoutButton(
        {required BuildContext context,
        required VoidCallback onPressedNo,
        required VoidCallback onPressedYes}) =>
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                Prompts.confirmSigningOut,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async => onPressedNo(),
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () async => onPressedYes(),
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

Widget buildChangePasswordButton(
        BuildContext context,
        FirebaseServicesProvider firebaseServicesNotifier,
        GenericFieldsProvider genericFieldsNotifier,
        GlobalKey<FormState> formKeyUpdatePassword) =>
    ElevatedButton(
      onPressed: firebaseServicesNotifier.getLoading
          ? null
          : () async => await showDialog(
                context: context,
                builder: (context) {
                  genericFieldsNotifier.clearPasswordFields();
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      'Enter New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200.h),
                          child: Form(
                            key: formKeyUpdatePassword,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                genericFieldsNotifier.buildPassword(setState),
                                SizedBox(height: 10.h),
                                genericFieldsNotifier
                                    .buildRepeatPassword(setState),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (formKeyUpdatePassword.currentState!.validate()) {
                            formKeyUpdatePassword.currentState?.save();
                            context.pop();
                            await firebaseServicesNotifier
                                .updatePassword(genericFieldsNotifier.password);
                          }
                        },
                        child: Text(
                          'Update Password',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  );
                },
              ),
      child: Text(
        'Change Password',
        style: TextStyle(fontSize: 12.sp),
      ),
    );

Widget buildChangeEmailButton(
        BuildContext context,
        FirebaseServicesProvider firebaseServicesNotifier,
        GenericFieldsProvider genericFieldsNotifier,
        GlobalKey<FormState> formKeyUpdateEmail) =>
    ElevatedButton(
      onPressed: firebaseServicesNotifier.getLoading
          ? null
          : () async => await showDialog(
                context: context,
                builder: (context) {
                  genericFieldsNotifier.clearEmailField();
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      'Enter New Email Address',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    content: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 160.h),
                      child: Form(
                        key: formKeyUpdateEmail,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            genericFieldsNotifier.buildEmail(),
                          ],
                        ),
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (formKeyUpdateEmail.currentState!.validate()) {
                            formKeyUpdateEmail.currentState?.save();
                            context.pop();
                            await firebaseServicesNotifier
                                .updateEmail(
                                    firebaseServicesNotifier.getCurrentUser!,
                                    genericFieldsNotifier.email)
                                .then(
                              (success) async {
                                if (success) {
                                  await firebaseServicesNotifier
                                      .getFirebaseFirestoreService
                                      .updateDocument(
                                          {
                                        ModelFields.email:
                                            genericFieldsNotifier.email,
                                        ModelFields.modifiedAt: DateTime.now()
                                      },
                                          FirebaseConstants.usersCollection,
                                          firebaseServicesNotifier
                                              .getCurrentUser!.uid);
                                }
                              },
                            );
                          }
                        },
                        child: Text(
                          'Confirm',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  );
                },
              ),
      child: Text(
        'Change Email Address',
        style: TextStyle(fontSize: 12.sp),
      ),
    );
