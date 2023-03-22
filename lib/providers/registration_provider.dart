import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/utilities/constants.dart';

class RegistrationProvider extends ChangeNotifier {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _uhsIdNumberController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  String _sexesDropdownValue = RegistrationConstants.sexes.first;
  String _classificationsDropdownValue =
      RegistrationConstants.classifications.first;
  String _civilStatusDropdownValue = RegistrationConstants.civilStatuses.first;
  String _vaccinationStatusDropdownValue =
      RegistrationConstants.vaccinationStatuses.first;
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  String get firstName => _firstNameController.text.trim();

  String get middleName => _middleNameController.text.trim();

  String get lastName => _lastNameController.text.trim();

  String get suffix => _suffixController.text.trim();

  int get age => int.parse(_ageController.text.trim());

  String get birthdate => _birthdateController.text.trim();

  String get email => _emailController.text.trim();

  String get phoneNumber => _phoneNumberController.text.trim();

  String get address => _addressController.text.trim();

  String get uhsIdNumber => _uhsIdNumberController.text.trim();

  String get sex => _sexesDropdownValue;

  String get classification => _classificationsDropdownValue;

  String get civilStatus => _civilStatusDropdownValue;

  String get vaccinationStatus => _vaccinationStatusDropdownValue;

  String get specialization => _specializationController.text.trim();

  String get password => _passwordController.text.trim();

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
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
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
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
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
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget buildSexesDropdown({bool editProfile = false}) {
    return DropdownButtonFormField<String>(
      value: editProfile ? _sexesDropdownValue : null,
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
      validator: (value) {
        return value == null || value.isEmpty ? 'Required' : null;
      },
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
          _birthdateController.text = pickedDate.toString();
        }
      },
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget buildEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: const InputDecoration(
          suffixIcon: Icon(Icons.email),
          labelText: 'Email Address',
          hintText: 'Enter email address'),
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
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
        if (value!.isEmpty) return 'Required';
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
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
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
      validator: (value) {
        return value!.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget buildVaccinationStatus({bool editProfile = false}) {
    return DropdownButtonFormField<String>(
      value: editProfile ? _vaccinationStatusDropdownValue : null,
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
      validator: (value) {
        return value == null || value.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget buildClassification({bool editProfile = false}) {
    return DropdownButtonFormField<String>(
      value: editProfile ? _classificationsDropdownValue : null,
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

  Widget buildCivilStatus({bool editProfile = false}) {
    return DropdownButtonFormField<String>(
      value: editProfile ? _civilStatusDropdownValue : null,
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
      validator: (value) {
        return value == null || value.isEmpty ? 'Required' : null;
      },
    );
  }

  Widget buildPassword([StateSetter? setState]) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter password',
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            if (setState == null) {
              _passwordVisible = !_passwordVisible;
              notifyListeners();
            } else {
              setState(() => _passwordVisible = !_passwordVisible);
            }
          },
        ),
      ),
      obscureText: !_passwordVisible,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required';
        } else if (value.length < 8) {
          return 'Too short';
        } else if (!(value.contains(RegExp('(?=.*?[A-Z])')))) {
          return 'Must contain an uppercase character.';
        } else if (!(value.contains(RegExp('(?=.*?[a-z])')))) {
          return 'Must contain a lowercase character.';
        } else if (!(value.contains(RegExp('(?=.*?[0-9])')))) {
          return 'Must contain a digit character.';
        } else if (!(value.contains(RegExp('(?=.*\\W)')))) {
          return 'Must contain a special character.';
        }
        return null;
      },
    );
  }

  Widget buildRepeatPassword([StateSetter? setState]) {
    return TextFormField(
      controller: _repeatPasswordController,
      decoration: InputDecoration(
        labelText: 'Repeat Password',
        hintText: 'Repeat password',
        suffixIcon: IconButton(
          icon: Icon(
              _repeatPasswordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            if (setState == null) {
              _repeatPasswordVisible = !_repeatPasswordVisible;
              notifyListeners();
            } else {
              setState(() => _repeatPasswordVisible = !_repeatPasswordVisible);
            }
          },
        ),
      ),
      obscureText: !_repeatPasswordVisible,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required';
        } else if (_passwordController.text.trim() !=
            _repeatPasswordController.text.trim()) {
          return 'Does not match password';
        }
        return null;
      },
    );
  }
}

final registrationProvider =
    ChangeNotifierProvider.autoDispose<RegistrationProvider>(
        (ref) => RegistrationProvider());
