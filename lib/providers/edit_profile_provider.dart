import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/utilities/constants.dart';

class EditProfileProvider extends ChangeNotifier {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _uhsIdNumberController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();

  String _sexesDropdownValue = RegistrationConstants.sexes.first;
  String _classificationsDropdownValue =
      RegistrationConstants.classifications.first;
  String _civilStatusDropdownValue = RegistrationConstants.civilStatuses.first;
  String _vaccinationStatusDropdownValue =
      RegistrationConstants.vaccinationStatuses.first;

  String get firstName => _firstNameController.text.trim();

  String get middleName => _middleNameController.text.trim();

  String get lastName => _lastNameController.text.trim();

  String get suffix => _suffixController.text.trim();

  int get age => int.parse(_ageController.text.trim());

  String get birthdate => _birthdateController.text.trim();

  String get phoneNumber => _phoneNumberController.text.trim();

  String get address => _addressController.text.trim();

  String get uhsIdNumber => _uhsIdNumberController.text.trim();

  String get sex => _sexesDropdownValue;

  String get classification => _classificationsDropdownValue;

  String get civilStatus => _civilStatusDropdownValue;

  String get vaccinationStatus => _vaccinationStatusDropdownValue;

  String get specialization => _specializationController.text.trim();

  set setFirstName(String firstName) {
    _firstNameController.text = firstName;
  }

  set setMiddleName(String middleName) {
    _middleNameController.text = middleName;
  }

  set setLastName(String lastName) {
    _lastNameController.text = lastName;
  }

  set setSuffix(String suffix) {
    _suffixController.text = suffix;
  }

  set setAge(String age) {
    _ageController.text = age;
  }

  set setSexesDropdownValue(String sexesDropdownValue) {
    _sexesDropdownValue = sexesDropdownValue;
  }

  set setPhoneNumber(String phoneNumber) {
    _phoneNumberController.text = phoneNumber;
  }

  set setBirthDate(String birthDate) {
    _birthdateController.text = birthDate;
  }

  set setAddress(String address) {
    _addressController.text = address;
  }

  set setUhsIdNumber(String uhsIdNumber) {
    _uhsIdNumberController.text = uhsIdNumber;
  }

  set setClassification(String classification) {
    _classificationsDropdownValue = classification;
  }

  set setCivilStatus(String civilStatus) {
    _civilStatusDropdownValue = civilStatus;
  }

  set setVaccinationStatus(String vaccinationStatus) {
    _vaccinationStatusDropdownValue = vaccinationStatus;
  }

  Widget buildFirstName() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name',
        hintText: 'Enter first name',
        suffixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget buildMiddleName() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _middleNameController,
      decoration: const InputDecoration(
        labelText: 'Middle Name (Optional)',
        hintText: 'Enter middle name',
        suffixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget buildLastName() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
        hintText: 'Enter last name',
        suffixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget buildSuffix() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _suffixController,
      decoration: const InputDecoration(
        labelText: 'Suffix (Optional)',
        hintText: 'Enter suffix',
        suffixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget buildAge() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: _ageController,
      decoration: const InputDecoration(
        labelText: 'Age',
        hintText: 'Enter age',
        suffixIcon: Icon(Icons.calendar_month),
      ),
    );
  }

  Widget buildSexesDropdown() {
    return DropdownButtonFormField<String>(
      value: _sexesDropdownValue,
      hint: const Text('Select sex'),
      alignment: AlignmentDirectional.center,
      decoration: const InputDecoration(
        suffixIcon: Icon(Icons.person),
      ),
      isExpanded: true,
      onChanged: (String? value) {
        _sexesDropdownValue = value!;
      },
      items: RegistrationConstants.sexes.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            alignment: AlignmentDirectional.center,
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }

  Widget buildBirthdate(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enableInteractiveSelection: false,
      controller: _birthdateController,
      decoration: const InputDecoration(
        labelText: 'Birthdate',
        hintText: 'Enter birthdate',
        suffixIcon: Icon(Icons.calendar_month),
        icon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          String formattedBirthDate = DateFormat('yMMMMd').format(pickedDate);
          _birthdateController.text = formattedBirthDate.toString();
        }
      },
    );
  }

  Widget buildPhoneNumber() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: _phoneNumberController,
      decoration: const InputDecoration(
          suffixIcon: Icon(Icons.phone),
          labelText: 'Phone Number',
          hintText: '(+63)'),
      validator: (value) {
        if (value!.isEmpty) return null;
        return !value.contains(RegExp('^(09|\\+639)\\d{9}\$'))
            ? 'Invalid format'
            : null;
      },
    );
  }

  Widget buildAddress() {
    return TextFormField(
      keyboardType: TextInputType.streetAddress,
      controller: _addressController,
      decoration: const InputDecoration(
          suffixIcon: Icon(Icons.house),
          labelText: 'Address',
          hintText: 'Enter current address'),
    );
  }

  Widget buildUhsIdNumber() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: _uhsIdNumberController,
      decoration: const InputDecoration(
          suffixIcon: FaIcon(FontAwesomeIcons.idCard),
          labelText: 'UHS ID Number (Optional)',
          hintText: 'Enter UHS ID No.'),
    );
  }

  Widget buildSpecialization() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _specializationController,
      decoration: const InputDecoration(
          suffixIcon: FaIcon(FontAwesomeIcons.idCard),
          labelText: 'Specialization',
          hintText: 'Enter specialization.'),
    );
  }

  Widget buildVaccinationStatus() {
    return DropdownButtonFormField<String>(
      value: _vaccinationStatusDropdownValue,
      hint: const Text('Select vaccination status'),
      alignment: AlignmentDirectional.center,
      isExpanded: true,
      decoration: const InputDecoration(
        suffixIcon: FaIcon(FontAwesomeIcons.syringe),
      ),
      onChanged: (String? value) {
        _vaccinationStatusDropdownValue = value!;
      },
      items: RegistrationConstants.vaccinationStatuses
          .map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            alignment: AlignmentDirectional.center,
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }

  Widget buildClassification() {
    return DropdownButtonFormField<String>(
      value: _classificationsDropdownValue,
      hint: const Text('Select classification'),
      alignment: AlignmentDirectional.center,
      decoration: const InputDecoration(
        suffixIcon: FaIcon(FontAwesomeIcons.school),
      ),
      isExpanded: true,
      onChanged: (String? value) {
        _classificationsDropdownValue = value!;
      },
      items:
          RegistrationConstants.classifications.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            alignment: AlignmentDirectional.center,
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }

  Widget buildCivilStatus() {
    return DropdownButtonFormField<String>(
      value: _civilStatusDropdownValue,
      hint: const Text('Select civil status'),
      alignment: AlignmentDirectional.center,
      decoration: const InputDecoration(
        suffixIcon: FaIcon(FontAwesomeIcons.ring),
      ),
      isExpanded: true,
      onChanged: (String? value) {
        _civilStatusDropdownValue = value!;
      },
      items: RegistrationConstants.civilStatuses.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            alignment: AlignmentDirectional.center,
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }

  updateName() {
    _firstNameController.text = 'HELOOOO';
  }
}

final editProfileProvider =
    ChangeNotifierProvider.autoDispose<EditProfileProvider>(
        (ref) => EditProfileProvider());
