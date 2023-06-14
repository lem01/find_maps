import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
//barra de busqueda
  static final TextEditingController controllerSearchAddress =
      TextEditingController();

  int _indexListWidget = 0;

  get indexListWidget => _indexListWidget;

  void setindexListWidget() {
    _indexListWidget == 0 ? _indexListWidget = 1 : _indexListWidget = 0;

    notifyListeners();
  }

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
