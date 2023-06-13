import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  String _address = '';
  TextEditingController _addressController = TextEditingController();

  String get address => _address;
  TextEditingController get addressController => _addressController;

  set setAddressController(TextEditingController value) {
    _addressController = value;
    notifyListeners();
  }

  set setAddressText(String value) {
    _address = value;
    notifyListeners();
  }
}
