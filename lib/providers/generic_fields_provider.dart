import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schedcare/utilities/constants.dart';

class GenericFieldsProvider extends ChangeNotifier {
  final TextEditingController _prefixController = TextEditingController();
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
  DateTime? _chosenDate;

  String _sexesDropdownValue = AppConstants.sexes.first;
  String _classificationsDropdownValue = AppConstants.classifications.first;
  String _civilStatusDropdownValue = AppConstants.civilStatuses.first;
  String _vaccinationStatusDropdownValue =
      AppConstants.vaccinationStatuses.first;
  bool _passwordVisible = false;
  bool _repeatPasswordVisible = false;

  String get prefix => _prefixController.text.trim();

  String get firstName => _firstNameController.text.trim();

  String get middleName => _middleNameController.text.trim();

  String get lastName => _lastNameController.text.trim();

  String get suffix => _suffixController.text.trim();

  int get age => int.parse(_ageController.text.trim());

  DateTime get birthdate => _chosenDate!;

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

  set setPrefix(String prefix) {
    _prefixController.text = prefix;
  }

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

  set setChosenDate(DateTime dateTime) {
    _chosenDate = dateTime;
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

  set setSpecialization(String specialization) {
    _specializationController.text = specialization;
  }

  void clearPasswordFields() {
    _passwordController.text = '';
    _repeatPasswordController.text = '';
  }

  void clearEmailField() {
    _emailController.text = '';
  }

  Widget buildPrefix() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _prefixController,
        decoration: InputDecoration(
          labelText: 'Prefix (Optional)',
          hintText: 'Enter prefix',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: const Icon(Icons.person),
        ),
      );

  Widget buildFirstName() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _firstNameController,
        decoration: InputDecoration(
          labelText: 'First Name',
          hintText: 'Enter first name',
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z ]'),
          )
        ],
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildMiddleName() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _middleNameController,
        decoration: InputDecoration(
          labelText: 'Middle Name (Optional)',
          hintText: 'Enter middle name',
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z ]'),
          )
        ],
      );

  Widget buildLastName() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _lastNameController,
        decoration: InputDecoration(
          labelText: 'Last Name',
          hintText: 'Enter last name',
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z ]'),
          )
        ],
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildSuffix() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _suffixController,
        decoration: InputDecoration(
          labelText: 'Suffix (Optional)',
          hintText: 'Enter suffix',
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      );

  Widget buildAge() => TextFormField(
        keyboardType: TextInputType.number,
        controller: _ageController,
        decoration: InputDecoration(
          labelText: 'Age',
          hintText: 'Enter age',
          suffixIcon: const Icon(Icons.calendar_month),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildSexesDropdown({bool editProfile = false}) =>
      DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Colors.grey[200],
        value: editProfile ? _sexesDropdownValue : null,
        hint: const Text('Select sex'),
        alignment: AlignmentDirectional.center,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        isExpanded: true,
        onChanged: (String? value) {
          _sexesDropdownValue = value!;
        },
        items: AppConstants.sexes.map<DropdownMenuItem<String>>(
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

  Widget buildBirthdate(BuildContext context) => TextFormField(
        readOnly: true,
        enableInteractiveSelection: false,
        controller: _birthdateController,
        decoration: InputDecoration(
          labelText: 'Birthdate',
          hintText: 'Enter birthdate',
          suffixIcon: const Icon(Icons.calendar_month),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1920),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null) {
            _chosenDate = pickedDate;
            _birthdateController.text = DateFormat('yMMMMd').format(pickedDate);
          }
        },
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildEmail() => TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: const Icon(Icons.email),
          labelText: 'Email Address',
          hintText: 'Enter email address',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Required';
          return EmailValidator.validate(value.trim())
              ? null
              : 'Invalid format';
        },
      );

  Widget buildPhoneNumber() => TextFormField(
        keyboardType: TextInputType.phone,
        controller: _phoneNumberController,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.sim_card),
          labelText: 'Phone Number',
          hintText: '(+63)',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value!.isEmpty) return 'Required';
          return !value.contains(RegExp('^(09|\\+639)\\d{9}\$'))
              ? 'Invalid format'
              : null;
        },
      );

  Widget buildAddress() => TextFormField(
        keyboardType: TextInputType.streetAddress,
        controller: _addressController,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.house),
          labelText: 'Address',
          hintText: 'Enter current address',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildUhsIdNumber() => TextFormField(
        keyboardType: TextInputType.number,
        controller: _uhsIdNumberController,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.credit_card),
          labelText: 'UHS ID Number (Optional)',
          hintText: 'Enter UHS ID No.',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp('[0-9]'),
          )
        ],
      );

  Widget buildSpecialization() => TextFormField(
        keyboardType: TextInputType.name,
        controller: _specializationController,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.work),
          labelText: 'Specialization',
          hintText: 'Enter specialization.',
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          return value!.isEmpty ? 'Required' : null;
        },
      );

  Widget buildVaccinationStatus({bool editProfile = false}) =>
      DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Colors.grey[200],
        value: editProfile ? _vaccinationStatusDropdownValue : null,
        hint: const Text('Select vaccination status'),
        alignment: AlignmentDirectional.center,
        isExpanded: true,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.health_and_safety),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (String? value) {
          _vaccinationStatusDropdownValue = value!;
        },
        items: AppConstants.vaccinationStatuses.map<DropdownMenuItem<String>>(
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

  Widget buildClassification({bool editProfile = false}) =>
      DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Colors.grey[200],
        value: editProfile ? _classificationsDropdownValue : null,
        hint: const Text('Select classification (Optional)'),
        alignment: AlignmentDirectional.center,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.account_box),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        isExpanded: true,
        onChanged: (String? value) {
          _classificationsDropdownValue = value!;
        },
        items: AppConstants.classifications.map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(
              alignment: AlignmentDirectional.center,
              value: value,
              child: Text(value),
            );
          },
        ).toList(),
      );

  Widget buildCivilStatus({bool editProfile = false}) =>
      DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(20),
        dropdownColor: Colors.grey[200],
        value: editProfile ? _civilStatusDropdownValue : null,
        hint: const Text('Select civil status'),
        alignment: AlignmentDirectional.center,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.safety_divider),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        isExpanded: true,
        onChanged: (String? value) {
          _civilStatusDropdownValue = value!;
        },
        items: AppConstants.civilStatuses.map<DropdownMenuItem<String>>(
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

  Widget buildPassword([StateSetter? setState]) => TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter password',
          suffixIcon: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              if (setState == null) {
                _passwordVisible = !_passwordVisible;
                notifyListeners();
              } else {
                setState(() => _passwordVisible = !_passwordVisible);
              }
            },
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
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

  Widget buildRepeatPassword([StateSetter? setState]) => TextFormField(
        controller: _repeatPasswordController,
        decoration: InputDecoration(
          labelText: 'Repeat Password',
          hintText: 'Repeat password',
          suffixIcon: IconButton(
            icon: Icon(_repeatPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off),
            onPressed: () {
              if (setState == null) {
                _repeatPasswordVisible = !_repeatPasswordVisible;
                notifyListeners();
              } else {
                setState(
                    () => _repeatPasswordVisible = !_repeatPasswordVisible);
              }
            },
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.grey[200],
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

final genericFieldsProvider =
    ChangeNotifierProvider.autoDispose<GenericFieldsProvider>(
        (ref) => GenericFieldsProvider());
