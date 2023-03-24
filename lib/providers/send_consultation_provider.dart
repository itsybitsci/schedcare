import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/utilities/constants.dart';

class SendConsultationProvider extends ChangeNotifier {
  final TextEditingController _consultationRequestBodyController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  DateTime? _chosenDate;
  TimeOfDay? _chosenTime;

  String _consultationTypeDropdownValue = AppConstants.consultationTypes.first;

  DateTime get dateTime => DateTime(_chosenDate!.year, _chosenDate!.month,
      _chosenDate!.day, _chosenTime!.hour, _chosenTime!.minute);

  String get consultationRequestBody =>
      _consultationRequestBodyController.text.trim();

  String get consultationType => _consultationTypeDropdownValue;

  Widget buildBody() => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w, maxHeight: 280.h),
        child: TextFormField(
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
      );

  Widget buildDatePicker(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 198.w),
        child: TextFormField(
          readOnly: true,
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

  Widget buildTimePicker(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 130.w),
        child: TextFormField(
          readOnly: true,
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
                _timeController.text = pickedTime.format(context);
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
                    time.hour + time.minute / 60 > 16
                ? 'Office hours only'
                : null;
          },
        ),
      );

  Widget buildConsultationType() => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: DropdownButtonFormField<String>(
          value: _consultationTypeDropdownValue,
          hint: const Text('Select sex'),
          alignment: AlignmentDirectional.center,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
          onChanged: (String? value) {
            _consultationTypeDropdownValue = value!;
          },
          items: AppConstants.consultationTypes.map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(
                alignment: AlignmentDirectional.center,
                value: value,
                child: Text(value),
              );
            },
          ).toList(),
          validator: (value) {
            return value == null || value.isEmpty ? 'Required' : null;
          },
        ),
      );
}

final sendConsultationProvider =
    ChangeNotifierProvider.autoDispose<SendConsultationProvider>(
        (ref) => SendConsultationProvider());
