import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/utilities/constants.dart';

class ConsultationRequestProvider extends ChangeNotifier {
  final TextEditingController _consultationRequestBodyController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  DateTime? _chosenDate;
  TimeOfDay? _chosenTime;
  PlatformFile? _pickedFile;

  String _consultationTypeDropdownValue = AppConstants.consultationTypes.first;

  DateTime get dateTime => DateTime(_chosenDate!.year, _chosenDate!.month,
      _chosenDate!.day, _chosenTime!.hour, _chosenTime!.minute);

  String get consultationRequestBody =>
      _consultationRequestBodyController.text.trim();

  String get consultationType => _consultationTypeDropdownValue;

  PlatformFile? get pickedFile => _pickedFile;

  set setConsultationRequestBody(String consultationRequestBody) {
    _consultationRequestBodyController.text = consultationRequestBody;
  }

  set setDate(DateTime dateTime) {
    _chosenDate = dateTime;
    _dateController.text = DateFormat('yMMMMd').format(dateTime);
  }

  set setTime(DateTime dateTime) {
    _chosenTime = TimeOfDay.fromDateTime(dateTime);
    _timeController.text = DateFormat('hh:mm a').format(dateTime);
  }

  set setConsultationTypeDropdownValue(String consultationType) {
    _consultationTypeDropdownValue = consultationType;
  }

  Widget buildBody({enabled = true}) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w, maxHeight: 280.h),
        child: Scrollbar(
          controller: _scrollController,
          child: TextFormField(
            readOnly: !enabled,
            enabled: true,
            scrollController: _scrollController,
            controller: _consultationRequestBodyController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textAlignVertical: TextAlignVertical.top,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              return value!.isEmpty ? 'Required' : null;
            },
          ),
        ),
      );

  Widget buildDatePicker(BuildContext context, {bool enabled = true}) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 198.w),
        child: TextFormField(
          readOnly: true,
          enabled: enabled,
          enableInteractiveSelection: false,
          controller: _dateController,
          decoration: InputDecoration(
            labelText: 'Date',
            hintText: 'Date',
            suffixIcon: const Icon(Icons.calendar_month),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day + 1),
              firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day + 1),
              lastDate: DateTime(2030),
            );

            if (pickedDate != null) {
              _chosenDate = pickedDate;
              _dateController.text = DateFormat('yMMMMd').format(pickedDate);
            }
          },
          validator: (value) {
            return value!.isEmpty ? 'Required' : null;
          },
        ),
      );

  Widget buildTimePicker(BuildContext context, {bool enabled = true}) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 130.w),
        child: TextFormField(
          readOnly: true,
          enabled: enabled,
          enableInteractiveSelection: false,
          controller: _timeController,
          decoration: InputDecoration(
            labelText: 'Time',
            hintText: 'Time',
            suffixIcon: const Icon(Icons.timer),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialEntryMode: TimePickerEntryMode.input,
              initialTime: const TimeOfDay(hour: 8, minute: 0),
            );

            if (pickedTime != null) {
              if (context.mounted) {
                _chosenTime = pickedTime;
                _timeController.text = DateFormat('hh:mm a').format(
                    DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute));
              }
            }
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Required';
            }
            TimeOfDay time = TimeOfDay.fromDateTime(
              DateFormat.jm().parse(value),
            );
            return time.hour + time.minute / 60 < 8 ||
                    (time.hour + time.minute / 60 > 11 &&
                        time.hour + time.minute / 60 < 13) ||
                    time.hour + time.minute / 60 > 15
                ? 'Office hours only'
                : null;
          },
        ),
      );

  Widget buildConsultationType({enabled = true}) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: DropdownButtonFormField<String>(
          value: _consultationTypeDropdownValue,
          alignment: AlignmentDirectional.center,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
          onChanged: enabled
              ? (String? value) => _consultationTypeDropdownValue = value!
              : null,
          focusNode: FocusNode(),
          items: AppConstants.consultationTypes.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                alignment: AlignmentDirectional.center,
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
        ),
      );
}

final consultationRequestProvider =
    ChangeNotifierProvider.autoDispose<ConsultationRequestProvider>(
        (ref) => ConsultationRequestProvider());
