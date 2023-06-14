import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeProvider extends ChangeNotifier {
//barra de busqueda
  static final TextEditingController controllerSearchAddress =
      TextEditingController();

// Localtation
  List<Placemark> _placeMark = [];

  List<Placemark> get placeMark => _placeMark;

set placeMark(List<Placemark> value) {
    _placeMark.clear();
    _placeMark.addAll(value);
    notifyListeners();
  }

String _distance = "";

String get distance => _distance;

set distance(value){
  _distance = value;
  notifyListeners();
}

String _timeDuration = "";

String get timeDuration => _timeDuration;

set timeDuration(value){
  _timeDuration = value;
  notifyListeners();
}

  

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
